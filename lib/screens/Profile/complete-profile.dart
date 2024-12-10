import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String token;

  CompleteProfileScreen({required this.token});

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? selectedObjective;
  String? selectedGender;

  void completeProfile(BuildContext context) async {
    if (selectedObjective == null ||
        selectedGender == null ||
        ageController.text.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor completa todos los campos.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      final response = await Dio().post(
        'http://192.168.1.223:4000/users/complete-profile',
        data: {
          'genero_usuario': selectedGender,
          'altura_usuario': double.tryParse(heightController.text),
          'peso_usuario': double.tryParse(weightController.text),
          'edad': int.tryParse(ageController.text),
          'objetivo': selectedObjective,
        },
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      if (response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.data['message'] ?? 'Perfil completado con éxito'),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.data['message'] ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al completar perfil: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 4,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Completa tu Información',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Género'),
              _buildGenderSelector(),
              SizedBox(height: 20),
              _buildSectionTitle('Altura (cm)'),
              _buildTextField(
                controller: heightController,
                labelText: 'Introduce tu altura',
                icon: Icons.height,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Peso (kg)'),
              _buildTextField(
                controller: weightController,
                labelText: 'Introduce tu peso',
                icon: Icons.fitness_center,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Edad (años)'),
              _buildTextField(
                controller: ageController,
                labelText: 'Introduce tu edad',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _buildSectionTitle('Objetivo'),
              _buildDropdown(),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => completeProfile(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Guardar Perfil',
                    style: TextStyle(fontSize: 18,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.teal.shade800,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGenderOption('Masculino', Icons.male),
        _buildGenderOption('Femenino', Icons.female),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedGender == gender ? Colors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: selectedGender == gender ? Colors.white : Colors.teal),
            SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selectedGender == gender ? Colors.white : Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
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
      decoration: InputDecoration(
        labelText: 'Selecciona un objetivo',
        prefixIcon: Icon(Icons.flag),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
