import 'package:flutter/material.dart';
import '../model/users.dart';
import '../model/movesense.dart';
import '../model/training.dart';
import '../model/storage.dart';

class HomeViewModel extends ChangeNotifier {
  final Player player;
  final MovesenseManager movesense;
  final TrainingRepository repository;
  final PlayerRepository playerRepository;

  HomeViewModel({
    required this.player,
    required this.movesense,
    required this.repository, required this.playerRepository,
  });

  bool isConnecting = false;
  String? errorMessage;

  bool get isConnected => movesense.isConnected;
  String? get batteryStatus => movesense.batteryStatus;

 
  TrainingSession? lastSession;
  bool isLoadingLastSession = false;

  
  Future<void> loadLastSession() async {
    isLoadingLastSession = true;
    notifyListeners();

    final sessions = await repository.getSessionsByPlayer(player.id);

    if (sessions.isNotEmpty) {
      sessions.sort((a, b) => b.date.compareTo(a.date));
      lastSession = sessions.first;
    } else {
      lastSession = null;
    }

    isLoadingLastSession = false;
    notifyListeners();
  }

 

  Future<void> connect() async {
    isConnecting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await movesense.connect();
      notifyListeners();
    } catch (e) {
      errorMessage = 'error connection movesense';
      notifyListeners();
    }

    isConnecting = false;
    notifyListeners();
  }

  Future<void> disconnectMovesense() async {
    try {
      await movesense.disconnect();
      notifyListeners();
    } catch (e) {
      errorMessage = 'error disconnection movesense';
      notifyListeners();
    }
  }
}
