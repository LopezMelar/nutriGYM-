import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RegisterScreen extends StatelessWidget {
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void registerUser(BuildContext context) async {
    try {
      final response = await Dio().post(
        'http://192.168.1.223:4000/users/register',
        data: {
          'nombre_usuario': nombreController.text,
          'apellido_usuario': apellidoController.text,
          'correo_usuario': correoController.text,
          'contraseña_usuario': passwordController.text,
          'edad': 0, // O el valor que desees enviar
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4DC39A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      _buildTextField('Nombre', nombreController, context),
                      const SizedBox(height: 15),
                      _buildTextField('Apellido', apellidoController, context),
                      const SizedBox(height: 15),
                      _buildTextField(
                          'Correo Electrónico', correoController, context),
                      const SizedBox(height: 15),
                      _buildTextField(
                        'Contraseña',
                        passwordController,
                        context,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        'Confirmar Contraseña',
                        confirmPasswordController,
                        context,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () => registerUser(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DC39A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Registrar',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "¿You have account? Login",
                            style: TextStyle(
                              color: Color(0xFF4DC39A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      BuildContext context, {bool isPassword = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4DC39A),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: const TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
