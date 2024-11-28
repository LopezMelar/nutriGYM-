import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dio/dio.dart';

class StatsScreen extends StatefulWidget {
  final String token; // Recibe el token de autenticación

  StatsScreen({required this.token});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Map<String, dynamic>> _stats = []; // Datos de las estadísticas

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    print('Método fetchStats ejecutándose...');

    try {
      final response = await Dio().get(
        'http://192.168.1.223:4000/users/stats',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );
      print('Respuesta completa del servidor: ${response.data}');
      final List<dynamic> data = response.data['data'] ?? [];

      setState(() {
        _stats = data.map<Map<String, dynamic>>((entry) {
          final fecha = entry['fecha'] ?? '';
          final caloriasTotales = double.tryParse(entry['calorias_totales'].toString()) ?? 0.0;
          final metaCalorias = double.tryParse(entry['meta_calorias'].toString()) ?? 0.0;

          return {
            'fecha': fecha,
            'calorias_totales': caloriasTotales,
            'meta_calorias': metaCalorias,
          };
        }).toList();
      });
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cargar estadísticas'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Contenido actual de _stats: $_stats');
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas'),
      ),
      body: _stats.isEmpty
          ? Center(child: Text('No hay datos disponibles para mostrar.'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Consumo vs Objetivo de Calorías',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelRotation: -45, // Rota las etiquetas para fechas largas
              ),
              title: ChartTitle(text: 'Consumo vs Objetivo de Calorías por Día'),
              legend: Legend(isVisible: true),
              series: <CartesianSeries>[
                // Serie para Calorías Consumidas
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: _stats,
                  xValueMapper: (data, _) => data['fecha'],
                  yValueMapper: (data, _) => data['calorias_totales'],
                  name: 'Consumidas',
                  color: Colors.blue, // Color de las barras consumidas
                ),
                // Serie para Meta de Calorías
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: _stats,
                  xValueMapper: (data, _) => data['fecha'],
                  yValueMapper: (data, _) => data['meta_calorias'],
                  name: 'Meta',
                  color: Colors.green, // Color de las barras meta
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
