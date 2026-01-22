import 'package:flutter/material.dart';
import '../model/users.dart';
import '../model/storage.dart';
import '../model/training.dart';

class CoachViewModel extends ChangeNotifier {
  final Coach coach;
  final PlayerRepository playerRepository;
  final TrainingRepository trainingRepository;

  bool isLoading = true;
  List<Player> _players = [];

  CoachViewModel({
    required this.coach,
    required this.playerRepository,
    required this.trainingRepository,
  });

  List<Player> get playersOfCoach => _players;

  /// 🔥 CARREGA PLAYERS ASSOCIADOS AO COACH
  Future<void> loadPlayers() async {
    isLoading = true;
    notifyListeners();

    final allPlayers = await playerRepository.getAll();

    _players = allPlayers
        .where((p) => p.coachId == coach.id)
        .toList();

    isLoading = false;
    notifyListeners();
  }

  /// 🔒 RESPEITA PERMISSÕES
  Future<List<TrainingSession>> getAuthorizedSessions(Player player) async {
    if (!player.permissions.trainingHistory) return [];
    return await trainingRepository.getSessionsByPlayer(player.id);
  }
}
