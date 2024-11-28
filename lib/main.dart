import 'package:flutter/material.dart';
import 'package:nutri_gym/screens/Home/HomeScreen.dart';
import 'package:nutri_gym/screens/LoginUsarios/LoginScreen.dart';
import 'package:nutri_gym/screens/LoginUsarios/RegisterScreen.dart';
import 'package:nutri_gym/screens/Profile/complete-profile.dart';
import 'package:nutri_gym/screens/Screens_Objetives/StatsScreen.dart';
import 'package:nutri_gym/screens/Screens_Objetives/recipes_screen.dart';
import 'package:nutri_gym/screens/welcome_screen/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriGym',
      initialRoute: '/', // Ruta inicial de la app
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => WelcomeScreen());
          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => HomeScreen(
                objective: args['objective'], // Pasa el objetivo
                token: args['token'],         // Pasa el token
                gender: args['gender'],       // Pasa el género
                weight: args['weight'],       // Pasa el peso
                height: args['height'],       // Pasa la altura
                age: args['age'],             // Pasa la edad
              ),
            );
          case '/stats':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => StatsScreen(
                token: args['token'], // Pasa el token para obtener estadísticas
              ),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/complete-profile':
            final args = settings.arguments as Map<String,dynamic>;
            return MaterialPageRoute(builder: (context) => CompleteProfileScreen( token: args['token'])
            );
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterScreen());

          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Pantalla no encontrada')),
              ),
            );
        }
      },
    );
  }
}
