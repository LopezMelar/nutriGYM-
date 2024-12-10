import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final List<dynamic> favoritos;

  FavoritesScreen({required this.favoritos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: favoritos.isEmpty
          ? Center(child: Text('No tienes recetas favoritas aún.'))
          : ListView.builder(
        itemCount: favoritos.length,
        itemBuilder: (context, index) {
          final recipe = favoritos[index];
          final String nombreReceta = recipe['nombre_receta'] ?? 'Receta sin nombre';
          final String imagen = recipe['imagen'] ?? '';
          final int calorias = recipe['calorias'] ?? 0;
          final String descripcion = recipe['descripcion'] ?? 'Sin descripción';

          return ListTile(
            leading: imagen.isNotEmpty
                ? Image.network(imagen, width: 50, fit: BoxFit.cover)
                : Icon(Icons.image_not_supported),
            title: Text(nombreReceta),
            subtitle: Text('$calorias Calorías'),
            onTap: () => _showRecipeDetails(context, recipe, index),
          );
        },
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, dynamic recipe, int index) {
    final String nombreReceta = recipe['nombre_receta'] ?? 'Receta sin nombre';
    final String imagen = recipe['imagen'] ?? '';
    final int calorias = recipe['calorias'] ?? 0;
    final String descripcion = recipe['descripcion'] ?? 'Sin descripción';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagen.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imagen,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                SizedBox(height: 16),
                Text(
                  nombreReceta,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '$calorias Calorías',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Text(
                  descripcion,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Cierra el modal
                      },
                      icon: Icon(Icons.close),
                      label: Text('Cerrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Cierra el modal
                        _removeFromFavorites(context, index);
                      },
                      icon: Icon(Icons.delete),
                      label: Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeFromFavorites(BuildContext context, int index) {
    favoritos.removeAt(index); // Elimina de la lista
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Receta eliminada de favoritos'),
      backgroundColor: Colors.red,
    ));
    (context as Element).reassemble(); //  la pantalla
  }
}
