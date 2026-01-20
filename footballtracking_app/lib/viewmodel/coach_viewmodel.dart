import '../model/app_model.dart';

class CoachViewModel {
  final Coach coach;
  final List<Player> allPlayers;
  final TrainingRepository repository; // 🔥 FALTAVA ISSO

  CoachViewModel({
    required this.coach,
    required this.allPlayers,
    required this.repository,
  });

  List<TrainingSession> getAuthorizedSessions(Player player) {
  if (!player.permissions.trainingHistory) {
    return [];
  }

  return repository.getSessionsByPlayer(player.id);

  
}





  /// Jogadores associados ao coach
  List<Player> get playersOfCoach {
    return allPlayers
        .where((p) => p.coachId == coach.id)
        .toList();
  }
}
