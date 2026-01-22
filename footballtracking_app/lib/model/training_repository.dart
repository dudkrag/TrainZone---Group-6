import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_model.dart';
import 'weather_model.dart';

class TrainingRepository {
  static const String _storageKey = 'training_sessions_v1';

  final List<TrainingSession> _sessions = [];

  List<TrainingSession> get allSessions => List.unmodifiable(_sessions);

  /// Load sessions from local storage (call once at app start)
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    final List<dynamic> list = jsonDecode(raw);
    _sessions
      ..clear()
      ..addAll(list.map((e) => _fromJson(e as Map<String, dynamic>)));
  }

  /// Add session + persist
  Future<void> addSession(TrainingSession session) async {
    _sessions.add(session);
    await _save();
  }

  List<TrainingSession> getSessionsByPlayer(String playerId) {
    return _sessions.where((s) => s.playerId == playerId).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_sessions.map(_toJson).toList());
    await prefs.setString(_storageKey, data);
  }

  // =========================
  // JSON helpers
  // =========================
  Map<String, dynamic> _toJson(TrainingSession s) => {
        'playerId': s.playerId,
        'avgHr': s.avgHr,
        'durationMs': s.duration.inMilliseconds,
        'dateIso': s.date.toIso8601String(),
        'idealZonePercentage': s.idealZonePercentage,
        'distanceMeters': s.distanceMeters,
        'avgSpeedMps': s.avgSpeedMps,
        'maxSpeedMps': s.maxSpeedMps,
        'weather': s.weather?.toJson(),
      };

  TrainingSession _fromJson(Map<String, dynamic> json) => TrainingSession(
        playerId: json['playerId'] as String,
        avgHr: (json['avgHr'] as num).toDouble(),
        duration: Duration(
          milliseconds: (json['durationMs'] as num).toInt(),
        ),
        date: DateTime.parse(json['dateIso'] as String),
        idealZonePercentage:
            (json['idealZonePercentage'] as num).toDouble(),
        distanceMeters:
            (json['distanceMeters'] as num?)?.toDouble(),
        avgSpeedMps:
            (json['avgSpeedMps'] as num?)?.toDouble(),
        maxSpeedMps:
            (json['maxSpeedMps'] as num?)?.toDouble(),
        weather: json['weather'] == null
            ? null
            : WeatherData.fromJson(
                json['weather'] as Map<String, dynamic>,
              ),
      );
}
