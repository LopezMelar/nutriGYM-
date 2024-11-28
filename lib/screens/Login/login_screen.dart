import 'package:flutter/material.dart';
import 'package:nutri_gym/services/api_service.dart';
import 'package:nutri_gym/services/local_storage.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response['token'] != null) {
        await LocalStorage.saveToken(response['token']);
        Navigator.pushReplacementNamed(context, '/home'); // Pantalla principal
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error al iniciar sesión')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) => value!.isEmpty ? 'Ingrese su correo' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) => value!.isEmpty ? 'Ingrese su contraseña' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Iniciar Sesión'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
