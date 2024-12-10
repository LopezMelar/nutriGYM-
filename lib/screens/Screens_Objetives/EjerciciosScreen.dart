import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ExercisesScreen extends StatefulWidget {
  final String token;

  ExercisesScreen({required this.token});

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<dynamic> _exercises = [];
  String _selectedGroup = 'Todos';

  final List<String> _muscleGroups = [
    'Todos',
    'Pecho',
    'Espalda',
    'Bíceps',
    'Tríceps',
    'Hombros',
    'Piernas'
  ];

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises([String group = 'Todos']) async {
    try {
      final response = await Dio().get(
        'http://192.168.1.223:4000/users/exercises',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
        queryParameters: group != 'Todos' ? {'group': group} : null,
      );

      setState(() {
        _exercises = response.data['data'];
        _selectedGroup = group;
      });
    } catch (e) {
      print('Error al cargar ejercicios: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cargar ejercicios'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          SizedBox(height: 10),
          _buildMuscleGroupFilter(),
          Expanded(
            child: _exercises.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return _buildExerciseCard(exercise);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _muscleGroups.length,
        itemBuilder: (context, index) {
          final group = _muscleGroups[index];
          final isSelected = _selectedGroup == group;
          return GestureDetector(
            onTap: () => fetchExercises(group),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ]
                    : null,
              ),
              child: Center(
                child: Text(
                  group,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              exercise['imagen'],
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              exercise['nombre_ejercicio'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Grupo: ${exercise['grupo_muscular']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
