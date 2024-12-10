import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nutri_gym/screens/notification_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _token;
  String _message = "Esperando notificaciones...";

  // Inicializa la instancia de FlutterLocalNotificationsPlugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
    _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    // Configuración de la notificación
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('app_icon');  // Reemplaza 'app_icon' con el nombre de tu icono
    final InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print("Flutter Local Notifications Initialized");
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Solicitar permisos para notificaciones (especialmente importante en iOS)
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Permisos para notificaciones otorgados");
    } else {
      print("Permisos para notificaciones denegados");
    }

    // Obtener el token FCM
    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print("Token FCM: $_token");
    });

    // Escuchar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      setState(() {
        _message = "Notificación recibida: ${message.notification?.title}";
      });

      // Mostrar notificación cuando se recibe un mensaje
      await _showNotification(message);
      print("Mensaje en primer plano: ${message.notification?.title}");
    });

    // Manejar notificaciones al abrir la app desde una notificación
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        setState(() {
          _message = "App abierta desde notificación: ${message.notification?.title}";
        });
        print("Mensaje al abrir la app: ${message.notification?.title}");
      }
    });
  }

  // Método para mostrar la notificación local
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your_channel_id',   // ID del canal
      'your_channel_name', // Nombre del canal
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',  // Usa solo el nombre sin la extensión
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,  // ID de la notificación
      message.notification?.title,  // Título de la notificación
      message.notification?.body,  // Cuerpo de la notificación
      notificationDetails,
      payload: 'item x',  // Información adicional
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones Firebase"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Token FCM: ${_token ?? 'Cargando...'}"),
            const SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
