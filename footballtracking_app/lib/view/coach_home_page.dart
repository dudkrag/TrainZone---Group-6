import 'package:flutter/material.dart';
import '../viewmodel/coach_viewmodel.dart';
import '../viewmodel/coach_player_viewmodel.dart';
import 'coach_playerData_page.dart';

class CoachHomePage extends StatefulWidget {
  final CoachViewModel viewModel;

  const CoachHomePage({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<CoachHomePage> createState() => _CoachHomePageState();
}

class _CoachHomePageState extends State<CoachHomePage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadPlayers(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Dashboard'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.playersOfCoach.isEmpty) {
            return const Center(
              child: Text('No players assigned to this coach'),
            );
          }

          return ListView.builder(
            itemCount: widget.viewModel.playersOfCoach.length,
            itemBuilder: (context, index) {
              final player = widget.viewModel.playersOfCoach[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(player.name),
                  subtitle: Text('ID: ${player.id}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoachPlayerPage(
                          viewModel: CoachPlayerViewModel(
                            player: player,
                            repository:
                                widget.viewModel.trainingRepository,
                          ),
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
