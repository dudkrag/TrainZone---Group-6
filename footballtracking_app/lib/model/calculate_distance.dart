import 'dart:async';
import 'dart:math';
import 'gps_model.dart';

class DistanceState {
  final List<GpsPoint> points;
  double totalDistanceMeters;

  DistanceState({
    List<GpsPoint>? points,
    this.totalDistanceMeters = 0,
  }) : points = points ?? [];

  double get totalDistanceKm => totalDistanceMeters / 1000.0;
}

class CalculateDistance {
  final GpsModel gps;

  StreamSubscription<GpsPoint>? _sub;

  // Filters
  double maxAccuracyMeters = 25;
  double maxJumpMeters = 80;

  final DistanceState state = DistanceState();

  bool get isRunning => _sub != null;

  CalculateDistance({required this.gps});

  void reset() {
    state.points.clear();
    state.totalDistanceMeters = 0;
  }

  void start(void Function(DistanceState state) onUpdate) {
    stop(); // ensure only one subscription

    _sub = gps.stream.listen((p) {
      // accuracy filter
      if (p.accuracy.isNaN || p.accuracy > maxAccuracyMeters) return;

      if (state.points.isNotEmpty) {
        final prev = state.points.last;
        final d = _haversineMeters(prev.lat, prev.lon, p.lat, p.lon);

        // jump/spike filter
        if (d > maxJumpMeters) return;

        state.totalDistanceMeters += d;
      }

      state.points.add(p);
      onUpdate(state);
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);
}
