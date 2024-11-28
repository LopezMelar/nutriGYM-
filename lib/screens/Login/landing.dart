import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Evitar que el contenido se oculte por el teclado
        backgroundColor: Colors.white, // Fondo blanco
        body: SingleChildScrollView(  // Agregamos un SingleChildScrollView para permitir desplazamiento
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Centra el contenido verticalmente
              crossAxisAlignment: CrossAxisAlignment.center,  // Centra el contenido horizontalmente
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),

                Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Cambié el texto a negro
                  ),
                ),
                SizedBox(height: 20.0),

                TextField(
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(color: Colors.black), // Cambié la etiqueta a negro
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 16.0),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.black), // Cambié la etiqueta a negro
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home'); // Cambiar a la pantalla principal después de registro
                  },
                  child: Text('Registrarse'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white, // Color de fondo blanco para el botón
                  ),
                ),
                SizedBox(height: 20.0),

                TextButton(
                  onPressed: () {},
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 10.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes una cuenta? ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Crea una',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.15), // Espaciado inferior para centrar mejor
              ],
            ),
          ),
        ),
      ),
    );
  }
}
