import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:nutri_gym/screens/Home/HomeScreen.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Función para calcular la edad
  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void loginUser(BuildContext context) async {
    try {
      final response = await Dio().post(
        'http://192.168.1.223:4000/users/login',
        data: {
          'correo_usuario': emailController.text,
          'contraseña_usuario': passwordController.text,
        },
      );

      print('Respuesta del servidor: ${response.data}');

      handleLoginResponse(context, response.data);
    } catch (e) {
      print('Error al iniciar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al iniciar sesión: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void handleLoginResponse(BuildContext context, Map<String, dynamic> responseData) {
    if (responseData['success']) {
      final token = responseData['token'];
      final isProfileComplete = responseData['user']['perfil_completo'] ?? false;
      final objective = responseData['user']['objetivo'];

      if (!isProfileComplete) {
        Navigator.pushReplacementNamed(
          context,
          '/complete-profile',
          arguments: {'token': token},
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              objective: objective,
              token: token,
              gender: responseData['user']['genero_usuario'],
              weight: double.parse(responseData['user']['peso_usuario'].toString()),
              height: double.parse(responseData['user']['altura_usuario'].toString()),
              age: calculateAge(DateTime.parse(responseData['user']['fecha_nacimiento'])),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseData['message']),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => loginUser(context),
              child: Text('Iniciar Sesión'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('¿No tienes una cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
