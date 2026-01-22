import '../model/app_model.dart';
import '../model/training_repository.dart';

class CoachViewModel {
  final Coach coach;
  final List<Player> allPlayers;
  final TrainingRepository repository;

  CoachViewModel({
    required this.coach,
    required this.allPlayers,
    required this.repository,
  });

  List<TrainingSession> getAuthorizedSessions(Player player) {
    if (!player.permissions.trainingHistory) return [];
    return repository.getSessionsByPlayer(player.id);
  }

  List<Player> get playersOfCoach {
    return allPlayers.where((p) => p.coachId == coach.id).toList();
  }
}
