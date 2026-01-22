import '../model/users.dart';


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

  final double lowZonePercentage;
  final double idealZonePercentage;
  final double highZonePercentage;

  final double? distanceMeters;
  final double? avgSpeedMps;
  final double? maxSpeedMps;

  TrainingSession({
    required this.playerId,
    required this.avgHr,
    required this.duration,
    required this.date,
    required this.lowZonePercentage,
    required this.idealZonePercentage,
    required this.highZonePercentage,
    this.distanceMeters,
    this.avgSpeedMps,
    this.maxSpeedMps,
  });

 
  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'avgHr': avgHr,
        'duration': duration.inSeconds,
        'date': date.toIso8601String(),
        'lowZonePercentage': lowZonePercentage,
        'idealZonePercentage': idealZonePercentage,
        'highZonePercentage': highZonePercentage,
        'distanceMeters': distanceMeters,
        'avgSpeedMps': avgSpeedMps,
        'maxSpeedMps': maxSpeedMps,
      };

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      playerId: json['playerId'] as String,
      avgHr: (json['avgHr'] as num).toDouble(),
      duration: Duration(seconds: json['duration'] as int),
      date: DateTime.parse(json['date'] as String),

      lowZonePercentage:
          (json['lowZonePercentage'] as num).toDouble(),
      idealZonePercentage:
          (json['idealZonePercentage'] as num).toDouble(),
      highZonePercentage:
          (json['highZonePercentage'] as num).toDouble(),

      distanceMeters: json['distanceMeters'] != null
          ? (json['distanceMeters'] as num).toDouble()
          : null,
      avgSpeedMps: json['avgSpeedMps'] != null
          ? (json['avgSpeedMps'] as num).toDouble()
          : null,
      maxSpeedMps: json['maxSpeedMps'] != null
          ? (json['maxSpeedMps'] as num).toDouble()
          : null,
    );
  }

  /// =====================
  /// CONVENIENCE GETTERS
  /// =====================
  double? get distanceKm =>
      distanceMeters == null ? null : distanceMeters! / 1000.0;

  double? get avgSpeedKmh =>
      avgSpeedMps == null ? null : avgSpeedMps! * 3.6;

  double? get maxSpeedKmh =>
      maxSpeedMps == null ? null : maxSpeedMps! * 3.6;
}
