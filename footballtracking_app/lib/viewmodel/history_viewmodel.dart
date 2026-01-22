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

  /// Newest sessions first
  List<TrainingSession> get history {
    final list = repository.getSessionsByPlayer(player.id);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  bool get isEmpty => history.isEmpty;
}
