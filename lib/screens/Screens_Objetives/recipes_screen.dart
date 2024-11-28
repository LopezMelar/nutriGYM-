import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:nutri_gym/services/api_service.dart'; // Asegúrate de tener la función updateProgress aquí
class RecipesScreen extends StatefulWidget {
  final String objective; // Adelgazar o Aumentar
  final String token; // Token del usuario para la autenticación
  final double caloriasObjetivo; // Calorías objetivo calculadas
  final double caloriasConsumidasActuales; // Calorías consumidas hasta ahora

  RecipesScreen({
    required this.objective,
    required this.token,
    required this.caloriasObjetivo,
    required this.caloriasConsumidasActuales, // Nuevo argumento
  });

  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<Map<String, dynamic>> favorites = [];

  Future<List<dynamic>> fetchRecipes() async {
    try {
      final response = await Dio().get(
        'http://192.168.1.223:4000/users/recipes/${widget.objective}',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );
      return response.data['data'];
    } catch (e) {
      print('Error al obtener recetas: $e');
      return [];
    }
  }

  Future<void> _addCalories(int calories) async {
    // Calcular el total de calorías después de agregar las nuevas
    double nuevoTotal = widget.caloriasConsumidasActuales + calories;

    try {
      // Actualizar progreso en la API (siempre permitir agregar las calorías)
      await ApiService.updateProgress(
        token: widget.token,
        caloriasConsumidas: calories,
        caloriasObjetivo: widget.caloriasObjetivo,
      );

      // Mostrar advertencia si el nuevo total excede las calorías objetivo
      if (nuevoTotal > widget.caloriasObjetivo) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Advertencia: Has excedido tu meta de calorías (${widget.caloriasObjetivo.toStringAsFixed(0)} kcal).',
          ),
          backgroundColor: Colors.amber,
        ));
      }

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Se han añadido $calories calorías a tu progreso.'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print('Error al actualizar progreso: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al añadir calorías.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar recetas'));
        }
        final recipes = snapshot.data ?? [];
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  if (recipe['imagen'] != null)
                    Expanded(
                      child: Image.network(recipe['imagen'], fit: BoxFit.cover),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(recipe['nombre_receta'], style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${recipe['calorias']} Calorías', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      _addCalories(recipe['calorias']);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
