import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String token; // Token recibido del login

  CompleteProfileScreen({required this.token});

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String? selectedObjective;
  DateTime? selectedDate;

  void completeProfile(BuildContext context) async {
    if (selectedObjective == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor selecciona un objetivo y tu fecha de nacimiento'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      final response = await Dio().post(
        'http://192.168.1.223:4000/users/complete-profile',
        data: {
          'genero_usuario': genderController.text,
          'altura_usuario': double.tryParse(heightController.text),
          'peso_usuario': double.tryParse(weightController.text),
          'objetivo': selectedObjective,
          'fecha_nacimiento': DateFormat('yyyy-MM-dd').format(selectedDate!), // Formatea la fecha
        },
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      // Imprimir la respuesta para depuración
      print('Respuesta del servidor: ${response.data}');

      // Verifica si el response.data existe y tiene success
      if (response.data != null && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Perfil completado con éxito'),
          backgroundColor: Colors.green,
        ));

        // Redirigir al Home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.data?['message'] ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Maneja cualquier otro error que ocurra
      print('Error al completar perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al completar perfil: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Completa tu Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: genderController,
                decoration: InputDecoration(labelText: 'Género'),
              ),
              TextField(
                controller: heightController,
                decoration: InputDecoration(labelText: 'Altura (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedObjective,
                items: [
                  DropdownMenuItem(value: 'adelgazar', child: Text('Adelgazar')),
                  DropdownMenuItem(value: 'aumentar', child: Text('Aumentar Músculo')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedObjective = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Selecciona un Objetivo'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                child: Text(selectedDate == null
                    ? 'Selecciona tu fecha de nacimiento'
                    : DateFormat('dd/MM/yyyy').format(selectedDate!)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => completeProfile(context),
                child: Text('Guardar Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
