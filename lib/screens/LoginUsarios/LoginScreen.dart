import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:nutri_gym/screens/Home/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
      final token = responseData['token']; // Obtén el token del login
      _saveToken(token); // Guarda el token

      final isProfileComplete = responseData['user']['perfil_completo'] == true || responseData['user']['perfil_completo'] == 1;
      final objective = responseData['user']['objetivo'];

      // Calcular edad si la fecha de nacimiento está presente
      int calculateAgeFromDOB(DateTime birthDate) {
        DateTime today = DateTime.now();
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        return age;
      }

      // Verifica si la edad está disponible o calcula a partir de la fecha de nacimiento
      int age = responseData['user']['edad'] != null
          ? responseData['user']['edad']
          : responseData['user']['fecha_nacimiento'] != null
          ? calculateAgeFromDOB(DateTime.parse(responseData['user']['fecha_nacimiento']))
          : 0; // Valor predeterminado si no hay edad ni fecha de nacimiento

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
              age: age, // Usa la edad calculada o proporcionada
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


// Método para guardar el token después de iniciar sesión
  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);  // Guarda el token
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
                borderRadius: BorderRadius.only(
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
                        'Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4DC39A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 70),
                      // Campo de email
                      // Campo de email
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4DC39A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: TextField(
                                  controller: emailController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: 'example@gmail.com',
                                    hintStyle: TextStyle(
                                      color: Colors.black38,
                                    ),
                                    border: InputBorder.none, // Sin bordes
                                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4DC39A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: '********',
                                    hintStyle: TextStyle(
                                      color: Colors.black38,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => loginUser(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DC39A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,  color:Colors.white),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            "don’t have account? click here",
                            style: TextStyle(
                              color: Color(0xFF4DC39A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFF4DC39A),
                              thickness: 1,
                              endIndent: 10,
                            ),
                          ),
                          Text(
                            'OR',
                            style: TextStyle(
                              color:Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFF4DC39A), // Color verde
                              thickness: 1,
                              indent: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              'assets/images/facebook.png',
                              height: 50,
                              width: 50,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              'assets/images/google.png',
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ],
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
}
