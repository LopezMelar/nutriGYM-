import 'package:flutter/material.dart';
import 'package:nutri_gym/services/api_service.dart';

class RegisterProgressScreen extends StatefulWidget {
  final String token; // Token de autenticación del usuario
  final double caloriasObjetivo; // Calorías objetivo calculadas

  RegisterProgressScreen({
    required this.token,
    required this.caloriasObjetivo,
  });

  @override
  _RegisterProgressScreenState createState() => _RegisterProgressScreenState();
}

class _RegisterProgressScreenState extends State<RegisterProgressScreen> {
  final TextEditingController _caloriasController = TextEditingController(); // Controlador para las calorías

  void _updateProgress() async {
    final int caloriasConsumidas = int.tryParse(_caloriasController.text) ?? 0;

    if (caloriasConsumidas <= 0) {
      // Mostrar un mensaje de error si las calorías ingresadas no son válidas
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor ingresa una cantidad válida de calorías.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      // Calcular el nuevo total después de agregar las calorías
      final double nuevoTotal = caloriasConsumidas + widget.caloriasObjetivo;

      // Llamar al método de la API para registrar el progreso
      await ApiService.updateProgress(
        token: widget.token,
        caloriasConsumidas: caloriasConsumidas,
        caloriasObjetivo: widget.caloriasObjetivo,
      );

      // Mostrar advertencia si el nuevo total excede el objetivo
      if (nuevoTotal > widget.caloriasObjetivo) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Advertencia: Has excedido tu meta de calorías. Total consumido: ${nuevoTotal.toStringAsFixed(1)} kcal',
          ),
          backgroundColor: Colors.amber,
        ));
      } else {
        // Mostrar un mensaje de éxito si no se excede el objetivo
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Progreso actualizado exitosamente.'),
          backgroundColor: Colors.green,
        ));
      }

      // Limpiar el campo de texto
      _caloriasController.clear();

      // Volver a la pantalla anterior (HomeScreen) y recargar estadísticas
      Navigator.pop(context, true); // Enviar una señal para recargar
    } catch (e) {
      // Mostrar un mensaje de error si falla la solicitud
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
