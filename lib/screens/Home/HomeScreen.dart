import 'package:flutter/material.dart';
import 'package:nutri_gym/screens/Screens_Objetives/recipes_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  final String objective;
  final String token;
  final String gender;
  final double weight;
  final double height;
  final int age;

  HomeScreen({
    required this.objective,
    required this.token,
    required this.gender,
    required this.weight,
    required this.height,
    required this.age,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  double tmb = 0.0;
  double caloriasObjetivo = 0.0;
  double totalCaloriasConsumidas = 0.0;
  List<Map<String, dynamic>> _stats = []; // Datos de las estadísticas
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    calculateMacros();
    fetchStats();
  }

  void calculateMacros() {
    tmb = widget.gender.toLowerCase() == 'masculino'
        ? 88.36 + (13.4 * widget.weight) + (4.8 * widget.height) - (5.7 * widget.age)
        : 447.6 + (9.2 * widget.weight) + (3.1 * widget.height) - (4.3 * widget.age);

    caloriasObjetivo = widget.objective == 'adelgazar'
        ? tmb * 0.8
        : widget.objective == 'aumentar'
        ? tmb * 1.2
        : tmb;
  }

  Future<void> fetchStats() async {
    try {
      final response = await Dio().get(
        'http://192.168.1.223:4000/users/stats',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      final List<dynamic> data = response.data['data'] ?? [];

      setState(() {
        _stats = data.map<Map<String, dynamic>>((entry) {
          return {
            'fecha': entry['fecha'] ?? '',
            'calorias_totales': double.tryParse(entry['calorias_totales'].toString()) ?? 0.0,
            'meta_calorias': (entry['meta_calorias'] as num?)?.toDouble() ?? 0.0,
          };
        }).toList();

        // Calcular el total de calorías consumidas
        totalCaloriasConsumidas = _stats.fold(0.0, (sum, stat) {
          return sum + (stat['calorias_totales'] ?? 0.0);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cargar estadísticas'),
        backgroundColor: Colors.red,
      ));
    }
  }
  void _checkCalorieGoal() {
    if (totalCaloriasConsumidas >= caloriasObjetivo) {
      // Mostrar el modal
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                  SizedBox(height: 16),
                  Text(
                    '¡Felicidades!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Has alcanzado tu meta de calorías por hoy.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Cierra automáticamente el modal después de 2 segundos
      Future.delayed(Duration(seconds: 2), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget _buildStatsPage() {
    double caloriasConsumidas = totalCaloriasConsumidas;
    double caloriasRestantes = (caloriasObjetivo - totalCaloriasConsumidas).clamp(0.0, double.infinity);

    return _stats.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No hay calorías consumidas para mostrar.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: fetchStats,
            child: Text('Recargar'),
          ),
        ],
      ),
    )
        : Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SfCircularChart(
                series: <CircularSeries>[
                  DoughnutSeries<Map<String, dynamic>, String>(
                    dataSource: [
                      {'type': 'Consumidas', 'value': caloriasConsumidas},
                      {'type': 'Restantes', 'value': caloriasRestantes},
                    ],
                    xValueMapper: (data, _) => data['type'],
                    yValueMapper: (data, _) => data['value'],
                    pointColorMapper: (data, _) =>
                    data['type'] == 'Consumidas' ? Colors.green : Colors.redAccent,
                    radius: '80%',
                    innerRadius: '60%',
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${caloriasConsumidas.toStringAsFixed(1)} kcal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    'Consumidas',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${caloriasRestantes.toStringAsFixed(1)} kcal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  Text(
                    'Restantes',
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(Icons.fastfood, color: Colors.green, size: 30),
                  SizedBox(height: 8),
                  Text(
                    'Consumidas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    '${caloriasConsumidas.toStringAsFixed(1)} kcal',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.redAccent, size: 30),
                  SizedBox(height: 8),
                  Text(
                    'Restantes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  Text(
                    '${caloriasRestantes.toStringAsFixed(1)} kcal',
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      RecipesScreen(
        objective: widget.objective,
        token: widget.token,
        caloriasObjetivo: caloriasObjetivo,
        caloriasConsumidasActuales: totalCaloriasConsumidas,
      ),
      Center(child: Text('Ejercicios: Próximamente')),
      _buildStatsPage(),
      Center(child: Text('Favoritos: Próximamente')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('NutriGym'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showObjectiveDetails,
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(0.6),
        onTap: (index) {
          setState(() {
            _currentIndex = index;

            if (_currentIndex == 2) { // Verifica si es la pestaña de estadísticas
              fetchStats().then((_) {
                _checkCalorieGoal(); // Solo mostrar mensaje aquí
              });
            }
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Recetas'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Ejercicios'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        ],
      ),
    );
  }

  void _showObjectiveDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Objetivos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text('TMB: ${tmb.toStringAsFixed(2)} kcal'),
                Text('Calorías objetivo: ${caloriasObjetivo.toStringAsFixed(2)} kcal'),
                Text('Objetivo: ${widget.objective.capitalize()}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}