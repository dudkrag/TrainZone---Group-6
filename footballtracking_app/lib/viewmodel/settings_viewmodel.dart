import 'package:flutter/material.dart';
import '../model/app_model.dart';

class SettingsViewModel extends ChangeNotifier {
  final Player player;

  SettingsViewModel({required this.player});

  /// =====================
  /// PLAYER INFO
  /// =====================

  void updateName(String value) {
    player.name = value;
    notifyListeners();
  }

  void updatePosition(String value) {
    player.position = value;
    notifyListeners();
  }

  void updateAge(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      player.age = parsed;
      notifyListeners();
    }
  }

  void updateCoachId(String value) {
    player.coachId = value;
    notifyListeners();
  }

  /// =====================
  /// PRIVACY PERMISSIONS
  /// =====================

  void toggleHeartRate(bool value) {
    player.permissions.heartRate = value;
    notifyListeners();
  }

  void toggleTrainingZones(bool value) {
    player.permissions.trainingZones = value;
    notifyListeners();
  }

  void toggleTrainingHistory(bool value) {
    player.permissions.trainingHistory = value;
    notifyListeners();
  }
}
