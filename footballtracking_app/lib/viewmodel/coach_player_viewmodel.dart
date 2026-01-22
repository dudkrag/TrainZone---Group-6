import '../model/app_model.dart';
import '../model/training_repository.dart';

class CoachPlayerViewModel {
  final Player player;
  final TrainingRepository repository;

  CoachPlayerViewModel({
    required this.player,
    required this.repository,
  });

  List<TrainingSession> get sessions {
    return repository.getSessionsByPlayer(player.id);
  }

  double get averageHr {
    if (sessions.isEmpty) return 0;
    final sum = sessions.map((s) => s.avgHr).fold<double>(0, (a, b) => a + b);
    return sum / sessions.length;
  }

  double get averageSpeedKmh {
    final speeds = sessions
        .map((s) => s.avgSpeedKmh)
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (speeds.isEmpty) return 0;
    final sum = speeds.fold<double>(0, (a, b) => a + b);
    return sum / speeds.length;
  }

  double get maxSpeedKmh {
    final speeds = sessions
        .map((s) => s.maxSpeedKmh)
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (speeds.isEmpty) return 0;
    double max = speeds.first;
    for (final v in speeds) {
      if (v > max) max = v;
    }
    return max;
  }

  double? get lastTemperatureC {
    if (sessions.isEmpty) return null;
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions.first.weather?.temperatureC;
  }

  double? get lastWindMps {
    if (sessions.isEmpty) return null;
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions.first.weather?.windSpeedMps;
  }
}
