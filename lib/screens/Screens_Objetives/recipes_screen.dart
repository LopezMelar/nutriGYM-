import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:nutri_gym/services/api_service.dart';

class RecipesScreen extends StatefulWidget {
  final String objective;
  final String token;
  final double caloriasObjetivo;
  final double caloriasConsumidasActuales;
  final Function refreshStats;
  final List<dynamic> favoritos; // Añadido para sincronizar favoritos.

  RecipesScreen({
    required this.objective,
    required this.token,
    required this.caloriasObjetivo,
    required this.caloriasConsumidasActuales,
    required this.refreshStats,
    required this.favoritos, // Recibe la lista de favoritos.
  });

  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  late double caloriasActuales;

  @override
  void initState() {
    super.initState();
    caloriasActuales = widget.caloriasConsumidasActuales;
  }

  Future<List<dynamic>> fetchRecipes() async {
    try {
      final response = await Dio().get(
        'http://192.168.1.223:4000/users/recipes/${widget.objective}',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );
      return response.data['data'];
    } catch (e) {
      return [];
    }
  }

  Future<void> _addCalories(int calories) async {
    try {
      await ApiService.updateProgress(
        token: widget.token,
        caloriasConsumidas: calories,
        caloriasObjetivo: widget.caloriasObjetivo,
      );

      setState(() {
        caloriasActuales += calories;
      });

      if (caloriasActuales > widget.caloriasObjetivo) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Advertencia: Has excedido tu meta de calorías (${widget.caloriasObjetivo.toStringAsFixed(0)} kcal).',
          ),
          backgroundColor: Colors.amber,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Se han añadido $calories calorías a tu progreso.'),
          backgroundColor: Colors.green,
        ));
      }

      widget.refreshStats();
    } catch (e) {
      print('Error al actualizar progreso: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al añadir calorías.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _toggleFavorite(dynamic recipe) {
    setState(() {
      if (widget.favoritos.contains(recipe)) {
        widget.favoritos.remove(recipe);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${recipe['nombre_receta']} eliminado de favoritos'),
          backgroundColor: Colors.red,
        ));
      } else {
        widget.favoritos.add(recipe);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${recipe['nombre_receta']} añadido a favoritos'),
          backgroundColor: Colors.green,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<dynamic>>(
        future: fetchRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar recetas'));
          }
          final recipes = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.only(top: 20.0),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final String nombreReceta = recipe['nombre_receta'] ?? 'Receta sin nombre';
              final String imagen = recipe['imagen'] ?? '';
              final int calorias = recipe['calorias'] ?? 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imagen.isNotEmpty
                          ? Image.network(
                        imagen,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                          : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(8),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => _addCalories(calorias),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(8),
                          backgroundColor: widget.favoritos.contains(recipe)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(recipe),
                        child: Icon(
                          widget.favoritos.contains(recipe)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombreReceta,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$calorias Calorías',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
