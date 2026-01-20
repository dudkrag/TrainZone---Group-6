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

  // Filtre (justér gerne)
  final double maxAccuracyMeters; // discard hvis dårlig GPS
  final double minStepMeters;     // discard små jitter-hop

  CalculateDistance({
    required this.gps,
    this.maxAccuracyMeters = 30.0,
    this.minStepMeters = 0.5,
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
        final d = _haversineMeters(_last!.lat, _last!.lon, p.lat, p.lon);

        if (d >= minStepMeters) {
          state = DistanceState(
            totalDistanceMeters: state.totalDistanceMeters + d,
          );
          onUpdate(state);
        }
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
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);
}
