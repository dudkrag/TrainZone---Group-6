import 'package:flutter/material.dart';
import '../model/users.dart';
import '../model/storage.dart';

class LoginViewModel extends ChangeNotifier {
  final PlayerRepository repository;

  List<Player> players = [];

  LoginViewModel(this.repository);

  ///get players when we open the app
  Future<void> loadPlayers() async {
    players = await repository.getAll();
    notifyListeners();
  }

  Future<void> addPlayer(Player player) async {
    await repository.add(player);
    await loadPlayers(); // update the list when we add the player
  }
}
