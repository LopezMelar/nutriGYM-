import 'package:flutter/material.dart';
import 'package:nutri_gym/services/api_service.dart';

class RegisterProgressScreen extends StatefulWidget {
  final String token;
  final double caloriasObjetivo;

  RegisterProgressScreen({
    required this.token,
    required this.caloriasObjetivo,
  });

  @override
  _RegisterProgressScreenState createState() => _RegisterProgressScreenState();
}

class _RegisterProgressScreenState extends State<RegisterProgressScreen> {
  final TextEditingController _caloriasController = TextEditingController();

  void _updateProgress() async {
    final int caloriasConsumidas = int.tryParse(_caloriasController.text) ?? 0;

    if (caloriasConsumidas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor ingresa una cantidad válida de calorías.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      final double nuevoTotal = caloriasConsumidas + widget.caloriasObjetivo;

      await ApiService.updateProgress(
        token: widget.token,
        caloriasConsumidas: caloriasConsumidas,
        caloriasObjetivo: widget.caloriasObjetivo,
      );

      if (nuevoTotal > widget.caloriasObjetivo) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Advertencia: Has excedido tu meta de calorías. Total consumido: ${nuevoTotal.toStringAsFixed(1)} kcal',
          ),
          backgroundColor: Colors.amber,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Progreso actualizado exitosamente.'),
          backgroundColor: Colors.green,
        ));
      }

      _caloriasController.clear();

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al actualizar progreso: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Progreso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calorías Objetivo: ${widget.caloriasObjetivo.toStringAsFixed(2)} kcal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _caloriasController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calorías Consumidas',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProgress,
              child: Text('Registrar Progreso'),
            ),
          ],
        ),
      ),
    );
  }
}
