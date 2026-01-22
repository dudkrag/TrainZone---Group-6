import 'dart:async';
import 'dart:math';
import 'gps_model.dart';

class DistanceState {
  final double totalDistanceMeters;

  const DistanceState({required this.totalDistanceMeters});

  double get totalDistanceKm => totalDistanceMeters / 1000.0;

  static const zero = DistanceState(totalDistanceMeters: 0.0);
}

class CalculateDistance {
  final GpsModel gps;
  StreamSubscription<GpsPoint>? _sub;

  DistanceState state = DistanceState.zero;

  GpsPoint? _last;

  /// Filters
  final double maxAccuracyMeters;      // discard hvis dårlig GPS
  final double minStepMeters;          // discard små jitter-hop
  final double maxReasonableSpeedMps;  // discard "jumps" der giver urealistisk speed
  final Duration minDeltaTime;         // undgå for tætte samples (micro-dt)

  CalculateDistance({
    required this.gps,
    this.maxAccuracyMeters = 20.0,                // strammere for sport
    this.minStepMeters = 2.0,                     // 0.5m var for følsomt
    this.maxReasonableSpeedMps = 12.0,            // ~43 km/h
    this.minDeltaTime = const Duration(milliseconds: 700),
  });

  void reset() {
    stop();
    state = DistanceState.zero;
    _last = null;
  }

  void start(void Function(DistanceState) onUpdate) {
    stop();

    _sub = gps.stream.listen((p) {
      if (p.accuracy > maxAccuracyMeters) return;

      if (_last != null) {
        final dt = p.timestamp.difference(_last!.timestamp);
        if (dt < minDeltaTime) {
          _last = p;
          return;
        }

        final d = _haversineMeters(_last!.lat, _last!.lon, p.lat, p.lon);
        if (d < minStepMeters) {
          _last = p;
          return;
        }

        final seconds = dt.inMilliseconds / 1000.0;
        if (seconds <= 0) {
          _last = p;
          return;
        }

        final impliedSpeed = d / seconds;

        // Reject GPS jumps
        if (impliedSpeed > maxReasonableSpeedMps) {
          _last = p;
          return;
        }

        state = DistanceState(
          totalDistanceMeters: state.totalDistanceMeters + d,
        );
        onUpdate(state);
      }

      _last = p;
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
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
