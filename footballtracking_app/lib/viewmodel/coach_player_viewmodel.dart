import '../model/app_model.dart';
import '../model/training_repository.dart';

class CoachPlayerViewModel {
  final Player player;
  final TrainingRepository repository;

  CoachPlayerViewModel({
    required this.player,
    required this.repository,
  });

  /// Permissions
  bool get canSeeHistory => player.permissions.trainingHistory;
  bool get canSeeHr => player.permissions.heartRate;
  bool get canSeeZones => player.permissions.trainingZones;

  /// Sessions (newest first). Empty if player disabled sharing history.
  List<TrainingSession> get sessions {
    if (!canSeeHistory) return [];
    final list = repository.getSessionsByPlayer(player.id);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get averageHr {
    if (!canSeeHr) return 0;
    final s = sessions;
    if (s.isEmpty) return 0;
    final sum = s.map((x) => x.avgHr).fold<double>(0, (a, b) => a + b);
    return sum / s.length;
  }

  double get averageSpeedKmh {
    final s = sessions;

    final speeds = s
        .map((x) => x.avgSpeedKmh)
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (speeds.isEmpty) return 0;
    final sum = speeds.fold<double>(0, (a, b) => a + b);
    return sum / speeds.length;
  }

  double get maxSpeedKmh {
    final s = sessions;

    final speeds = s
        .map((x) => x.maxSpeedKmh)
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
    final s = sessions;
    if (s.isEmpty) return null;
    return s.first.weather?.temperatureC;
  }

  double? get lastWindMps {
    final s = sessions;
    if (s.isEmpty) return null;
    return s.first.weather?.windSpeedMps;
  }
}
