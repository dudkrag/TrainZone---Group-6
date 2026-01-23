import 'package:flutter/material.dart';
import '../model/users.dart';
import '../model/training.dart';
import '../model/storage.dart';

class CoachPlayerViewModel extends ChangeNotifier {
  final Player player;
  final TrainingRepository repository;

  List<TrainingSession> sessions = [];
  bool isLoading = true;

  CoachPlayerViewModel({
    required this.player,
    required this.repository,
  });

  //permissions
  bool get canSeeHistory => player.permissions.trainingHistory;
  bool get canSeeHeartRate => player.permissions.heartRate;
  bool get canSeeZones => player.permissions.trainingZones;

  
  Future<void> loadSessions() async {
    isLoading = true;
    notifyListeners();

    if (!canSeeHistory) {
      sessions = [];
    } else {
      sessions = await repository.getSessionsByPlayer(player.id);
    }

    isLoading = false;
    notifyListeners();
  }
}
