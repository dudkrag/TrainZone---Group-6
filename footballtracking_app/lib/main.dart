import 'package:flutter/material.dart';
import 'model/app_model.dart';
<<<<<<< HEAD
=======
import 'model/gps_model.dart';
>>>>>>> calculate_speed
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
<<<<<<< HEAD
 
    //example of user      - REMEMBER TO CHANGE HEREEEEEEE
=======
    final MovesenseManager movesenseManager = MovesenseManager();
    final GpsModel gpsModel = GpsModel();

>>>>>>> calculate_speed
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
        permissions: DataPermissions(),
        restingHr: 60,
      ),
      Player(
        id: 'player2',
        name: 'Bruno',
        position: 'Defender',
        age: 30,
        coachId: coach.id,
        permissions: DataPermissions(),
        restingHr: 65,
      ),
    ];

<<<<<<< HEAD

    final Player currentPlayer = allPlayers.first;

    
         //should i move to viewmodel?
=======
    final Player currentPlayer = allPlayers.first;

>>>>>>> calculate_speed
    final HomeViewModel homeViewModel = HomeViewModel(
      player: currentPlayer,
      movesense: movesenseManager,
      repository: repository,
    );

    final CoachViewModel coachViewModel = CoachViewModel(
      coach: coach,
      allPlayers: allPlayers,
      repository: repository,
    );

<<<<<<< HEAD
   
=======
>>>>>>> calculate_speed
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrainZone',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
<<<<<<< HEAD

      routes: {  //login
       
=======
      routes: {
>>>>>>> calculate_speed
        '/': (context) => WelcomePage(
              homeViewModel: homeViewModel,
              coachViewModel: coachViewModel,
            ),
<<<<<<< HEAD

        
=======
>>>>>>> calculate_speed
        '/home': (context) => HomePage(
              viewModel: homeViewModel,
              // NOTE: HomePage will create TrainingViewModel; we pass gps via constructor below
              gpsModel: gpsModel,
            ),
<<<<<<< HEAD

        
=======
>>>>>>> calculate_speed
        '/coach': (context) => CoachHomePage(
              viewModel: coachViewModel,
            ),
      },
    );
  }
}
