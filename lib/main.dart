import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nutri_gym/screens/Home/HomeScreen.dart';
import 'package:nutri_gym/screens/LoginUsarios/LoginScreen.dart';
import 'package:nutri_gym/screens/LoginUsarios/RegisterScreen.dart';
import 'package:nutri_gym/screens/Profile/complete-profile.dart';
import 'package:nutri_gym/screens/Screens_Objetives/StatsScreen.dart';
import 'package:nutri_gym/screens/notification_screen.dart';
import 'package:nutri_gym/screens/welcome_screen/welcome_screen.dart';

/// Manejador para notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje recibido en segundo plano: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Registrar manejador de notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Obtener y mostrar el token FCM para pruebas
  FirebaseMessaging.instance.getToken().then((token) {
    print('FCM Token: $token');
  }).catchError((error) {
    print('Error al obtener el token: $error');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriGym',
      initialRoute: '/',
      onGenerateRoute: (settings) {

        switch (settings.name) {

          case '/':
            return MaterialPageRoute(builder: (context) => WelcomeScreen());

          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => HomeScreen(
                objective: args['objective'],
                token: args['token'],
                gender: args['gender'],
                weight: args['weight'],
                height: args['height'],
                age: args['age'],
              ),
            );
          case '/stats':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => StatsScreen(
                token: args['token'],
                caloriasObjetivo: args['caloriasObjetivo'], // Agrega el argumento necesario
              ),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/complete-profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CompleteProfileScreen(
                token: args['token'],
              ),
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
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  @override
  void initState() {
    super.initState();

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano: ${message.notification?.title}');
      _showNotificationDialog(message);
    });

    // Manejar mensajes cuando la app se abre desde una notificación
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print(
            'Mensaje recibido al abrir la app desde una notificación: ${message.notification?.title}');
      }
    });
  }

  void _showNotificationDialog(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message.notification?.title ?? 'Notificación'),
        content: Text(message.notification?.body ?? 'Sin contenido'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WelcomeScreen();
  }
}
