import '../model/app_model.dart';

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
    return sessions
            .map((s) => s.avgHr)
            .reduce((a, b) => a + b) /
        sessions.length;
  }
}
