import 'package:flutter/material.dart';
import '../model/storage.dart';
import '../viewmodel/login_viewmodel.dart';
import '../viewmodel/coach_login_viewmodel.dart';
import '../view/player_login_page.dart';
import '../view/coach_login_page.dart';

class WelcomePage extends StatelessWidget {
  final PlayerRepository playerRepository;
  final TrainingRepository trainingRepository;
  final CoachRepository coachRepository;

  const WelcomePage({
    Key? key,
    required this.playerRepository,
    required this.trainingRepository,
    required this.coachRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TrainZone',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            /// PLAYER LOGIN
            SizedBox(
              width: 200,
              child: OutlinedButton(
                child: const Text('Player'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerLoginPage(
                        viewModel: LoginViewModel(playerRepository),
                        repository: trainingRepository,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// COACH LOGIN
            SizedBox(
              width: 200,
              child: OutlinedButton(
                child: const Text('Coach'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CoachLoginPage(
                        viewModel:
                            CoachLoginViewModel(coachRepository),
                        trainingRepository: trainingRepository,
                        playerRepository: playerRepository,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
