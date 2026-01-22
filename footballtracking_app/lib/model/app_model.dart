import 'weather_model.dart';
import 'dart:async';
import 'package:movesense_plus/movesense_plus.dart';

class Player {
  final String id;
  String name;
  String position;
  String coachId;
  int age;
  int restingHr;
  DataPermissions permissions;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.coachId,
    required this.age,
    required this.restingHr,
    required this.permissions,
  });
}

class DataPermissions {
  bool heartRate;
  bool trainingZones;
  bool trainingHistory;

  DataPermissions({
    this.heartRate = true,
    this.trainingZones = true,
    this.trainingHistory = true,
  });
}

class Coach {
  final String id;
  final String name;

  Coach({
    required this.id,
    required this.name,
  });
}

enum TrainingZone {
  low,
  ideal,
  high,
}

class TrainingLogic {
  final Player player;

  TrainingLogic({required this.player});

  int get maxHr => 220 - player.age;

  TrainingZone calculateZone(int hr) {
    final double percent = hr / maxHr;

    if (percent < 0.60) {
      return TrainingZone.low;
    } else if (percent <= 0.80) {
      return TrainingZone.ideal;
    } else {
      return TrainingZone.high;
    }
  }
}

class TrainingSession {
  final String playerId;
  final double avgHr;
  final Duration duration;
  final DateTime date;
  final double idealZonePercentage;

  /// GPS distance in meters (optional)
  final double? distanceMeters;

  /// Speed metrics (optional) stored as meters/second
  final double? avgSpeedMps;
  final double? maxSpeedMps;

  /// Weather (optional)
  final WeatherData? weather;

  TrainingSession({
    required this.playerId,
    required this.avgHr,
    required this.duration,
    required this.date,
    required this.idealZonePercentage,
    this.distanceMeters,
    this.avgSpeedMps,
    this.maxSpeedMps,
    this.weather,
  });

  /// Convenience getters for UI
  double? get distanceKm =>
      distanceMeters == null ? null : distanceMeters! / 1000.0;

  double? get avgSpeedKmh => avgSpeedMps == null ? null : avgSpeedMps! * 3.6;
  double? get maxSpeedKmh => maxSpeedMps == null ? null : maxSpeedMps! * 3.6;

  String get weatherText {
    if (weather == null) return '--';
    return '${weather!.temperatureC.toStringAsFixed(1)}°C, '
        '${weather!.windSpeedMps.toStringAsFixed(1)} m/s';
  }

  /// JSON (optional – for saving sessions)
  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'avgHr': avgHr,
        'durationMs': duration.inMilliseconds,
        'dateIso': date.toIso8601String(),
        'idealZonePercentage': idealZonePercentage,
        'distanceMeters': distanceMeters,
        'avgSpeedMps': avgSpeedMps,
        'maxSpeedMps': maxSpeedMps,
        'weather': weather?.toJson(),
      };

  factory TrainingSession.fromJson(Map<String, dynamic> json) => TrainingSession(
        playerId: json['playerId'] as String,
        avgHr: (json['avgHr'] as num).toDouble(),
        duration: Duration(milliseconds: (json['durationMs'] as num).toInt()),
        date: DateTime.parse(json['dateIso'] as String),
        idealZonePercentage: (json['idealZonePercentage'] as num).toDouble(),
        distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
        avgSpeedMps: (json['avgSpeedMps'] as num?)?.toDouble(),
        maxSpeedMps: (json['maxSpeedMps'] as num?)?.toDouble(),
        weather: json['weather'] == null
            ? null
            : WeatherData.fromJson(json['weather'] as Map<String, dynamic>),
      );
}

class MovesenseManager {
  static const String macAddress = '0C:8C:DC:1B:23:61'; // change if needed
  MovesenseDevice? _device;
  StreamSubscription<MovesenseHR>? _hrSub;

  String? batteryStatus;
  bool get isConnected => _device != null;

  Future<void> connect() async {
    _device = MovesenseDevice(address: macAddress);
    _device!.connect();

    final battery = await _device!.getBatteryStatus();
    batteryStatus = battery.name;
  }

  Future<void> disconnect() async {
    stopHrStream();
    _device?.disconnect();
    _device = null;
    batteryStatus = null;
  }

  /// HEART RATE STREAM
  void startHrStream(void Function(int hr) onData) {
    if (_device == null) return;

    _hrSub = _device!.hr.listen((data) {
      onData(data.average);
    });
  }

  void stopHrStream() {
    _hrSub?.cancel();
  }
}
