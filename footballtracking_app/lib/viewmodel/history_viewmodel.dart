import 'package:flutter/material.dart';
import '../model/app_model.dart';
import '../model/training_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final TrainingRepository repository;
  final Player player;

  HistoryViewModel({
    required this.repository,
    required this.player,
  });

  List<TrainingSession> get history {
    return repository.getSessionsByPlayer(player.id);
  }

  bool get isEmpty => history.isEmpty;
}
