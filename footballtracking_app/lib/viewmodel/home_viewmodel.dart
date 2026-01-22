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

  /// 🔹 Última sessão salva (vinda do banco)
  TrainingSession? lastSession;
  bool isLoadingLastSession = false;

  /// 🔹 Carrega a última sessão do jogador
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

  // =========================
  // Movesense connection
  // =========================

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
      errorMessage = 'error desconnection movesense';
      notifyListeners();
    }
  }
}
