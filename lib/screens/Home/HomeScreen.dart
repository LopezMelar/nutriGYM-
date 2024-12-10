import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nutri_gym/screens/Screens_Objetives/EjerciciosScreen.dart';
import 'package:nutri_gym/screens/Screens_Objetives/StatsScreen.dart';
import 'package:nutri_gym/screens/Screens_Objetives/favorites.dart';
import 'package:nutri_gym/screens/Screens_Objetives/recipes_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  final String objective;
  final String token;
  final String gender;
  final double weight;
  final double height;
  final int age;

  HomeScreen({
    required this.objective,
    required this.token,
    required this.gender,
    required this.weight,
    required this.height,
    required this.age,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  double tmb = 0.0;
  double caloriasObjetivo = 0.0;
  double totalCaloriasConsumidas = 0.0;
  List<Map<String, dynamic>> _stats = [];
  late List<Widget> _pages;
  List<dynamic> favoritos = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    calculateMacros();
    fetchStats();
    _initializeLocalNotifications();
    _initializeFirebaseMessaging();
  }

  Future<void> fetchStats() async {
    try {
      final response = await Dio().get(
        'http://192.168.1.223:4000/users/stats',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      final List<dynamic> data = response.data['data'] ?? [];

      setState(() {
        _stats = data.map<Map<String, dynamic>>((entry) {
          return {
            'fecha': entry['fecha'] ?? '',
            'calorias_totales': double.tryParse(entry['calorias_totales'].toString()) ?? 0.0,
            'meta_calorias': (entry['meta_calorias'] as num?)?.toDouble() ?? 0.0,
          };
        }).toList();

        totalCaloriasConsumidas = _stats.fold(0.0, (sum, stat) {
          return sum + (stat['calorias_totales'] ?? 0.0);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cargar estadísticas'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void calculateMacros() {
    tmb = widget.gender.toLowerCase() == 'masculino'
        ? 88.36 + (13.4 * widget.weight) + (4.8 * widget.height) - (5.7 * widget.age)
        : 447.6 + (9.2 * widget.weight) + (3.1 * widget.height) - (4.3 * widget.age);

    caloriasObjetivo = widget.objective == 'adelgazar'
        ? tmb * 0.8
        : widget.objective == 'aumentar'
        ? tmb * 1.2
        : tmb;
  }

  Future<void> _initializeFirebaseMessaging() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Permisos para notificaciones otorgados");
    } else {
      print("Permisos para notificaciones denegados");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Mensaje recibido en primer plano: ${message.notification?.title}');
      await _showNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Mensaje recibido en segundo plano: ${message.notification?.title}');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print("Flutter Local Notifications Initialized");
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: 'item x',
    );
  }

  void _checkCalorieGoal() {
    if (totalCaloriasConsumidas >= caloriasObjetivo) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                  SizedBox(height: 16),
                  Text(
                    '¡Felicidades!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Has alcanzado tu meta de calorías por hoy.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      Future.delayed(Duration(seconds: 2), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> appBarTitles = [
      'Recetas',
      'Ejercicios',
      'Estadísticas',
      'Favoritos',
    ];

    _pages = [
      RecipesScreen(
        objective: widget.objective,
        token: widget.token,
        caloriasObjetivo: caloriasObjetivo,
        caloriasConsumidasActuales: totalCaloriasConsumidas,
        refreshStats: fetchStats,
        favoritos: favoritos,
      ),
      ExercisesScreen(token: widget.token),
      StatsScreen(
        token: widget.token,
        caloriasObjetivo: caloriasObjetivo,
      ),
      FavoritesScreen(favoritos: favoritos),
    ];


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: Center(
              child: Text(
                appBarTitles[_currentIndex],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.white),
                onPressed: _showObjectiveDetails,
              ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade700,
                    Colors.blue.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            elevation: 4,
            centerTitle: true,
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(0.6),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) fetchStats();
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Recetas'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Ejercicios'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        ],
      ),
    );
  }


  void _showObjectiveDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Mis Objetivos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'TMB: ${tmb.toStringAsFixed(2)} kcal',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  'Calorías objetivo: ${caloriasObjetivo.toStringAsFixed(2)} kcal',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  'Objetivo: ${widget.objective.capitalize()}',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.green.shade700, backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
