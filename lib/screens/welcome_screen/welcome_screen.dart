import 'package:flutter/material.dart';
import 'package:nutri_gym/screens/LoginUsarios/LoginScreen.dart';


class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),

          AnimatedPositioned(
            duration: Duration(seconds: 2),
            top: 100.0,
            left: 50.0,
            child: CircleAvatar(
              radius: 35.0,
              backgroundImage: AssetImage('assets/images/Pesa_icon.png'), // Tu imagen
            ),
          ),

          AnimatedPositioned(
            duration: Duration(seconds: 3),
            top: 200.0,
            left: -60.0,
            child: CircleAvatar(
              radius: 80.0,
              backgroundImage: AssetImage('assets/images/apple_icon.jpg'), // Tu imagen
            ),
          ),

          AnimatedPositioned(
            duration: Duration(seconds: 4),
            top: 200.0,
            right: -20.0,
            child: CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('assets/images/correr_icon.png'), // Tu imagen
            ),
          ),

          // Imagen flotante 4
          AnimatedPositioned(
            duration: Duration(seconds: 5),
            top: 300.0,
            right: 60.0,
            child: CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('assets/images/timer_icon.png'), // Tu imagen
            ),
          ),

          // Imagen flotante 5
          AnimatedPositioned(
            duration: Duration(seconds: 6),
            top: 120.0,
            right: 100.0,
            child: CircleAvatar(
              radius: 80.0,
              backgroundImage: AssetImage('assets/images/hearth_icon.png'), // Tu imagen
            ),
          ),

          // Imagen flotante 6
          AnimatedPositioned(
            duration: Duration(seconds: 7),
            top: 300.0,
            left: 100.0,
            child: CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('assets/images/gym_girl.jpg'), // Tu imagen
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height / 1.5,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Bienvenido a NutriGym',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tu app personalizada de\n nutrición y ejercicios',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 50.0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                    transitionDuration: Duration(seconds: 1),
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
