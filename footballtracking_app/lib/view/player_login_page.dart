import 'package:flutter/material.dart';
import 'package:TrainZone/model/gps_model.dart';
import '../viewmodel/login_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';
import '../model/storage.dart';
import '../model/movesense.dart';
import 'add_player_page.dart';
import 'home_page.dart';

class PlayerLoginPage extends StatefulWidget {
  final LoginViewModel viewModel;
  final TrainingRepository repository;

  const PlayerLoginPage({
    Key? key,
    required this.viewModel,
    required this.repository,
  }) : super(key: key);

  @override
  State<PlayerLoginPage> createState() => _PlayerLoginPageState();
}

class _PlayerLoginPageState extends State<PlayerLoginPage> {

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadPlayers(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPlayerPage(
                    onSave: widget.viewModel.addPlayer,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.viewModel.players.length,
            itemBuilder: (context, index) {
              final player = widget.viewModel.players[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(player.name),
                  subtitle: Text(player.position),
                  onTap: () {
                    final homeViewModel = HomeViewModel(
                      player: player,
                      movesense: MovesenseManager(),
                      repository: widget.repository,
                      playerRepository: PlayerRepository(),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          viewModel: homeViewModel,
                          gpsModel: GpsModel(), playerRepository: PlayerRepository() , 
                          trainingRepository: TrainingRepository(), 
                          coachRepository: CoachRepository(),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
