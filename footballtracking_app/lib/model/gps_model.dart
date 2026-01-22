import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GpsPoint {
  final double lat;
  final double lon;
  final double accuracy; 
  final DateTime timestamp;

  final double speedMps;

  GpsPoint({
    required this.lat,
    required this.lon,
    required this.accuracy,
    required this.timestamp,
    required this.speedMps,
  });

  factory GpsPoint.fromPosition(Position p) {
    final ts = p.timestamp;

    final spd = (p.speed.isNaN || p.speed < 0) ? 0.0 : p.speed;

    return GpsPoint(
      lat: p.latitude,
      lon: p.longitude,
      accuracy: p.accuracy,
      timestamp: ts,
      speedMps: spd,
    );
  }
}

class GpsModel {
  StreamSubscription<Position>? _sub;
  final StreamController<GpsPoint> _controller =
      StreamController<GpsPoint>.broadcast();

  bool get isTracking => _sub != null;
  Stream<GpsPoint> get stream => _controller.stream;

  String? lastError;  //handle error with msg

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
  );

  Future<bool> ensurePermissions() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        lastError = 'Location services are disabled.';
        return false;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        lastError = 'Location permission denied.';
        return false;  
      }


      lastError = null;
      return true;
    } catch (e) {
      lastError = 'Permission error: $e';
      return false;
    }
  }

  Future<void> start() async {
    final ok = await ensurePermissions();
    if (!ok) return;

    await stop();

    _sub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(
      (pos) {
        _controller.add(GpsPoint.fromPosition(pos));
      },
      onError: (err) {
        lastError = 'GPS stream error: $err';
      },
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
