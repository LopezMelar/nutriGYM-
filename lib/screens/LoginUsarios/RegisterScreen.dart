import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RegisterScreen extends StatelessWidget {
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final generoController = TextEditingController();

  void registerUser(BuildContext context) async {
    try {
      final response = await Dio().post(
        'http://192.168.1.223:4000/users/register',
        data: {
          'nombre_usuario': nombreController.text,
          'apellido_usuario': apellidoController.text,
          'correo_usuario': correoController.text,
          'contraseña_usuario': passwordController.text,
        },
      );

      if (response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Usuario registrado con éxito'),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.data['message'] ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al registrar usuario: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              TextField(
                controller: correoController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => registerUser(context),
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
