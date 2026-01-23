import 'package:flutter/material.dart';
import '../viewmodel/coach_login_viewmodel.dart';
import '../view/coach_home_page.dart';
import '../view/add_coach_page.dart';
import '../viewmodel/coach_viewmodel.dart';
import '../model/storage.dart';

class CoachLoginPage extends StatelessWidget {
  final CoachLoginViewModel viewModel;
  final TrainingRepository trainingRepository;
  final PlayerRepository playerRepository; 

  const CoachLoginPage({
    Key? key,
    required this.viewModel,
    required this.trainingRepository,
    required this.playerRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    viewModel.loadCoaches();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCoachPage(
                    onSave: viewModel.addCoach,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.coaches.length,
            itemBuilder: (context, index) {
              final coach = viewModel.coaches[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(coach.name),
                  subtitle: Text('ID: ${coach.id}'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoachHomePage(
                          viewModel: CoachViewModel(
                            coach: coach,
                            trainingRepository: trainingRepository, 
                            playerRepository: playerRepository,     
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
