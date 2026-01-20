import 'package:flutter/material.dart';
import '../viewmodel/coach_viewmodel.dart';
import '../viewmodel/coach_player_viewmodel.dart';
import 'coach_playerData_page.dart';

class CoachHomePage extends StatelessWidget {
  final CoachViewModel viewModel;

  const CoachHomePage({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final players = viewModel.playersOfCoach;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Dashboard'),
      ),
      body: players.isEmpty
          ? const Center(
              child: Text('No associated player '),
            )
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(player.name),
                    subtitle: Text(player.position),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CoachPlayerDetailPage(
                            viewModel: CoachPlayerViewModel(
                              player: player,
                              repository: viewModel.repository,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
