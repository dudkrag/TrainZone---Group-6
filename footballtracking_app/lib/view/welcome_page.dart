import 'package:flutter/material.dart';

import '../viewmodel/home_viewmodel.dart';
import '../viewmodel/coach_viewmodel.dart';

class WelcomePage extends StatelessWidget {
  final HomeViewModel homeViewModel;
  final CoachViewModel coachViewModel;

  const WelcomePage({
    Key? key,
    required this.homeViewModel,
    required this.coachViewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome to TrainZone',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            /// =======================
            /// PLAYER
            /// =======================
            SizedBox(
              width: 220,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('Player'),
              ),
            ),

            const SizedBox(height: 16),

            /// =======================
            /// COACH
            /// =======================
            SizedBox(
              width: 220,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/coach');
                },
                child: const Text('Coach'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
