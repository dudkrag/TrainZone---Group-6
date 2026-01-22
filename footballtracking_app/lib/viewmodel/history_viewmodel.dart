import 'package:flutter/material.dart';
import '../model/users.dart';
import '../model/training.dart';
import '../model/storage.dart';
import 'dart:io';


class HistoryViewModel extends ChangeNotifier {
  final TrainingRepository repository;
  final Player player;

  List<TrainingSession> sessions = [];
  bool isLoading = true;

  HistoryViewModel({
    required this.repository,
    required this.player,
  });

  Future<void> loadHistory() async {
    isLoading = true;
    notifyListeners();

    sessions = await repository.getSessionsByPlayer(player.id);

    isLoading = false;
    notifyListeners();
  }

  bool get isEmpty => sessions.isEmpty;

  ///PYTHON
  Future<File> exportHistory() async {

    if (sessions.isEmpty) {
      sessions = await repository.getSessionsByPlayer(player.id);
    }

    return ExportService.exportPlayerSessions(
      player: player,
      sessions: sessions,
    );
  }
}
