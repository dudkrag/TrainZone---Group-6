import 'dart:async';
import 'dart:math';
import 'gps_model.dart';

class SpeedState {
  final double currentSpeedMps; // display speed (stabil, live)
  final double avgSpeedMps;     // distance / time (for accepted segments)
  final double maxSpeedMps;

  const SpeedState({
    required this.currentSpeedMps,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
  });

  double get currentKmh => currentSpeedMps * 3.6;
  double get avgKmh => avgSpeedMps * 3.6;
  double get maxKmh => maxSpeedMps * 3.6;

  static const zero = SpeedState(
    currentSpeedMps: 0,
    avgSpeedMps: 0,
    maxSpeedMps: 0,
  );
}

class SpeedCalculator {
  final GpsModel gps;
  StreamSubscription<GpsPoint>? _sub;

  SpeedState state = SpeedState.zero;

  GpsPoint? _last;

  // Distance/time for avg (accepted segments only)
  double _distForAvg = 0.0;
  Duration _timeForAvg = Duration.zero;

  // Moving time (Whoop/Strava style)
  Duration _movingTime = Duration.zero;

  // Display smoothing
  double _displayEmaMps = 0.0;

  // "Zero lock" hysteresis
  bool _lockedZero = true;
  Duration _belowThresholdTime = Duration.zero;

  // Tuning knobs (defaults tuned for running + walking outdoors)
  final double maxAccuracyMeters;     // ignore worse points
  final Duration minDeltaTime;        // avoid micro dt
  final double maxReasonableSpeedMps; // reject jumps
  final double minMoveMetersGood;     // movement threshold when accuracy is good
  final double minMoveMetersNoisy;    // movement threshold when accuracy is noisy
  final double emaAlpha;              // responsiveness

  // Display lock thresholds
  final double zeroLockKmh;
  final double unlockKmh;
  final Duration zeroLockDelay;

  // Moving-time threshold (only count as moving above this)
  final double movingThresholdKmh;

  SpeedCalculator({
    required this.gps,
    this.maxAccuracyMeters = 25.0,
    this.minDeltaTime = const Duration(milliseconds: 900),
    this.maxReasonableSpeedMps = 12.0, // ~43 km/h
    this.minMoveMetersGood = 1.2,
    this.minMoveMetersNoisy = 2.8,
    this.emaAlpha = 0.22,
    this.zeroLockKmh = 1.2,
    this.unlockKmh = 2.2,
    this.zeroLockDelay = const Duration(seconds: 2),
    this.movingThresholdKmh = 2.0, // count moving time only if >= 2.0 km/h
  });

  Duration get movingTime => _movingTime;

  void reset() {
    stop();
    state = SpeedState.zero;
    _last = null;
    _distForAvg = 0.0;
    _timeForAvg = Duration.zero;
    _movingTime = Duration.zero;
    _displayEmaMps = 0.0;
    _lockedZero = true;
    _belowThresholdTime = Duration.zero;
  }

  void start(void Function(SpeedState) onUpdate) {
    stop();

    _sub = gps.stream.listen((p) {
      // Hard reject very bad GPS
      if (p.accuracy > maxAccuracyMeters) return;

      if (_last == null) {
        _last = p;
        return;
      }

      final dt = p.timestamp.difference(_last!.timestamp);
      if (dt < minDeltaTime) {
        _last = p;
        return;
      }

      final seconds = dt.inMilliseconds / 1000.0;
      if (seconds <= 0) {
        _last = p;
        return;
      }

      final d = _haversineMeters(_last!.lat, _last!.lon, p.lat, p.lon);

      // Movement threshold depends on accuracy
      final minMove = (p.accuracy <= 15.0) ? minMoveMetersGood : minMoveMetersNoisy;

      // If almost no movement, raw speed is 0
      double rawMps = 0.0;
      if (d >= minMove) {
        rawMps = d / seconds;
      }

      // Reject jumps (position spikes)
      if (rawMps > maxReasonableSpeedMps) {
        _last = p;
        return;
      }

      // Update avg ONLY when we accept a plausible segment (rawMps > 0)
      if (rawMps > 0) {
        _distForAvg += d;
        _timeForAvg += dt;
      }

      // Smooth raw into display speed
      _displayEmaMps = _ema(rawMps, _displayEmaMps);

      // Apply zero-lock hysteresis
      final displayKmh = _displayEmaMps * 3.6;

      if (_lockedZero) {
        if (displayKmh >= unlockKmh) {
          _lockedZero = false;
          _belowThresholdTime = Duration.zero;
        } else {
          _displayEmaMps = 0.0;
        }
      } else {
        if (displayKmh < zeroLockKmh) {
          _belowThresholdTime += dt;
          if (_belowThresholdTime >= zeroLockDelay) {
            _lockedZero = true;
            _displayEmaMps = 0.0;
            _belowThresholdTime = Duration.zero;
          }
        } else {
          _belowThresholdTime = Duration.zero;
        }
      }

      // Moving time (Strava/Whoop style): count dt only when display speed is above threshold
      if ((_displayEmaMps * 3.6) >= movingThresholdKmh) {
        _movingTime += dt;
      }

      final avgMps = (_timeForAvg.inMilliseconds == 0)
          ? 0.0
          : _distForAvg / (_timeForAvg.inMilliseconds / 1000.0);

      final newMax = max(state.maxSpeedMps, _displayEmaMps);

      state = SpeedState(
        currentSpeedMps: _displayEmaMps,
        avgSpeedMps: avgMps,
        maxSpeedMps: newMax,
      );

      _last = p;
      onUpdate(state);
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  double _ema(double x, double prev) {
    if (prev == 0.0) return x;
    return (emaAlpha * x) + ((1.0 - emaAlpha) * prev);
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);
}
