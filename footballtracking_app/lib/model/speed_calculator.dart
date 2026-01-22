import 'dart:async';
import 'dart:math';
import 'gps_model.dart';

class SpeedState {
  final double currentSpeedMps; // øjeblikkelig (glattet)
  final double avgSpeedMps;     // tid-vægtet
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

  // Til avg-speed beregning
  double _distanceMetersForAvg = 0;
  Duration _timeForAvg = Duration.zero;

  // Sidste punkt til fallback-beregning
  GpsPoint? _last;

  // Glatning (EMA)
  double _emaSpeedMps = 0.0;
  final double smoothingAlpha; // 0..1

  // Filtre
  final double maxReasonableSpeedMps; // fx 12 m/s ~ 43 km/t
  final double maxAccuracyMeters;     // discard hvis dårlig GPS
  final Duration minDeltaTime;        // undgå micro-dt
  final double minDistanceForAvgMeters;

  SpeedCalculator({
    required this.gps,
    this.smoothingAlpha = 0.25,
    this.maxReasonableSpeedMps = 12.0,
    this.maxAccuracyMeters = 20.0,
    this.minDeltaTime = const Duration(milliseconds: 700),
    this.minDistanceForAvgMeters = 2.0,
  });

  void reset() {
    stop();

    state = SpeedState.zero;

    _distanceMetersForAvg = 0;
    _timeForAvg = Duration.zero;

    _last = null;
    _emaSpeedMps = 0.0;
  }

  void start(void Function(SpeedState) onUpdate) {
    stop();

    _sub = gps.stream.listen((p) {
      // filtrér noisy GPS
      if (p.accuracy > maxAccuracyMeters) return;

      final rawSpeedMps = _computeSpeedMps(p);
      if (rawSpeedMps.isNaN) return;

      // discard urealistiske spikes
      final clamped = rawSpeedMps.clamp(0.0, maxReasonableSpeedMps);

      // EMA smoothing
      _emaSpeedMps = (_emaSpeedMps == 0.0)
          ? clamped
          : (smoothingAlpha * clamped) + ((1 - smoothingAlpha) * _emaSpeedMps);

      // Update avg (tid-vægtet) baseret på distance mellem punkter
      if (_last != null) {
        final dt = p.timestamp.difference(_last!.timestamp);
        if (dt >= minDeltaTime) {
          final d = _haversineMeters(_last!.lat, _last!.lon, p.lat, p.lon);

          if (d >= minDistanceForAvgMeters) {
            final seconds = dt.inMilliseconds / 1000.0;
            if (seconds > 0) {
              final implied = d / seconds;

              // samme jump-filter som distance
              if (implied <= maxReasonableSpeedMps) {
                _distanceMetersForAvg += d;
                _timeForAvg += dt;
              }
            }
          }
        }
      }

      final avgMps = _timeForAvg.inMilliseconds == 0
          ? 0.0
          : _distanceMetersForAvg / (_timeForAvg.inMilliseconds / 1000.0);

      final maxMps = max(state.maxSpeedMps, _emaSpeedMps);

      state = SpeedState(
        currentSpeedMps: _emaSpeedMps,
        avgSpeedMps: avgMps,
        maxSpeedMps: maxMps,
      );

      _last = p;
      onUpdate(state);
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  double _computeSpeedMps(GpsPoint p) {
    // Primært: brug sensor speed hvis tilgængeligt
    if (p.speedMps > 0) return p.speedMps;

    // Fallback: beregn fra lat/lon
    if (_last == null) return 0.0;

    final dt = p.timestamp.difference(_last!.timestamp);
    if (dt.inMilliseconds <= 0) return 0.0;

    final d = _haversineMeters(_last!.lat, _last!.lon, p.lat, p.lon);
    return d / (dt.inMilliseconds / 1000.0);
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // earth radius meters
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);
}
