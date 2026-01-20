import 'package:flutter/material.dart';
import '../model/app_model.dart';

class HistoryViewModel extends ChangeNotifier {
  final TrainingRepository repository;
  final Player player;

  HistoryViewModel({
    required this.repository,
    required this.player,
  });

  /// Lista de treinos do jogador
  List<TrainingSession> get history {
    return repository.getSessionsByPlayer(player.id);
  }

  bool get isEmpty => history.isEmpty;
}
