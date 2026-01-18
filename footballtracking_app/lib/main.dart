import 'package:flutter/material.dart';

import 'model/app_model.dart';

import 'view/welcome_page.dart';
import 'view/home_page.dart';
import 'view/coach_home_page.dart';

import 'viewmodel/home_viewmodel.dart';
import 'viewmodel/coach_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TrainingRepository repository = TrainingRepository();
 
    //example of user      - REMEMBER TO CHANGE HEREEEEEEE
    final Coach coach = Coach(
      id: 'coach1',
      name: 'Coach Ana',
    );
    final List<Player> allPlayers = [
      Player(
        id: 'player1',
        name: 'Ana',
        position: 'Midfielder',
        age: 23,
        coachId: coach.id,
        permissions: DataPermissions(), restingHr: 60,
      ),
      Player(
        id: 'player2',
        name: 'Bruno',
        position: 'Defender',
        age: 30,
        coachId: coach.id,
        permissions: DataPermissions(), restingHr: 65,
      ),
    ];


    final Player currentPlayer = allPlayers.first;

    
         //should i move to viewmodel?
    final HomeViewModel homeViewModel = HomeViewModel(
      player: currentPlayer,
      movesense: MovesenseManager(),
      repository: repository,
    );

    final CoachViewModel coachViewModel = CoachViewModel(
      coach: coach,
      allPlayers: allPlayers,
      repository: repository,
    );

   
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrainZone',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),

      initialRoute: '/',

      routes: {  //login
       
        '/': (context) => WelcomePage(
              homeViewModel: homeViewModel,
              coachViewModel: coachViewModel,
            ),

        
        '/home': (context) => HomePage(
              viewModel: homeViewModel,
            ),

        
        '/coach': (context) => CoachHomePage(
              viewModel: coachViewModel,
            ),
      },
    );
  }
}
