import 'package:flutter/material.dart';
import 'model/storage.dart';
import 'view/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {


    // =========================
    // GLOBAL SINGLETONS
    // =========================
    final TrainingRepository trainingRepository = TrainingRepository();
    final PlayerRepository playerRepository = PlayerRepository();
    final CoachRepository coachRepository = CoachRepository();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrainZone',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomePage(
        playerRepository: playerRepository,
        trainingRepository: trainingRepository, coachRepository: coachRepository,
      ),
    );
  }
}
