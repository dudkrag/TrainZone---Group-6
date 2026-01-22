import 'package:flutter/material.dart';
import '../model/users.dart';
import '../model/storage.dart';

class CoachLoginViewModel extends ChangeNotifier {
  final CoachRepository repository;

  List<Coach> coaches = [];

  CoachLoginViewModel(this.repository);

  Future<void> loadCoaches() async {
    coaches = await repository.getAll();
    notifyListeners();
  }

  Future<void> addCoach(Coach coach) async {
    await repository.add(coach);
    await loadCoaches();
  }
}
