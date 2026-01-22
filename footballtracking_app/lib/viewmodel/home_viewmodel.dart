import 'package:flutter/material.dart';
import '../model/app_model.dart';
import '../model/training_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final Player player;
  final MovesenseManager movesense;
  final TrainingRepository repository;

  HomeViewModel({
    required this.player,
    required this.movesense,
    required this.repository,
  });

  bool isConnecting = false;
  String? errorMessage;

  bool get isConnected => movesense.isConnected;
  String? get batteryStatus => movesense.batteryStatus;

  TrainingSession? get lastSession {
    final sessions = repository.getSessionsByPlayer(player.id);
    if (sessions.isEmpty) return null;

    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions.first;
  }

  Future<void> connect() async {
    isConnecting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await movesense.connect();
    } catch (e) {
      errorMessage = 'error connection movesense';
    }

    isConnecting = false;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await movesense.disconnect();
    notifyListeners();
  }
}
