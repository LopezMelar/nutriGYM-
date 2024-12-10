import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dio/dio.dart';

class StatsScreen extends StatefulWidget {
  final String token;
  final double caloriasObjetivo;

  StatsScreen({
    required this.token,
    required this.caloriasObjetivo,
  });

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Map<String, dynamic>> _stats = [];

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
          final caloriasTotales =
              double.tryParse(entry['calorias_totales'].toString()) ?? 0.0;
          final metaCalorias =
              double.tryParse(entry['meta_calorias'].toString()) ?? 0.0;

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

  void _showGoalModal(double caloriasObjetivo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Meta Calórica',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 300,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      DoughnutSeries<Map<String, dynamic>, String>(
                        dataSource: [
                          {'meta_calorias': caloriasObjetivo}
                        ],
                        xValueMapper: (data, _) => 'Meta',
                        yValueMapper: (data, _) => data['meta_calorias'],
                        pointColorMapper: (_, __) => Colors.blueAccent,
                        dataLabelMapper: (data, _) =>
                        '${data['meta_calorias'].toStringAsFixed(0)} kcal',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        innerRadius: '50%',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(fontSize: 16,  color: Colors.white,),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Contenido actual de _stats: $_stats');

    final List<Map<String, dynamic>> chartData = _stats.isNotEmpty
        ? _stats
        : [
      {
        'calorias_totales': 0.0,
        'meta_calorias': widget.caloriasObjetivo,
      }
    ];

    final double caloriasConsumidas = chartData[0]['calorias_totales'];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fondo del gráfico
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.green.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  // Gráfico de dona
                  SfCircularChart(
                    title: ChartTitle(
                      text: 'Progreso Diario',
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CircularSeries>[
                      // Serie para calorías consumidas
                      DoughnutSeries<Map<String, dynamic>, String>(
                        dataSource: chartData,
                        xValueMapper: (data, _) => 'Consumidas',
                        yValueMapper: (data, _) => data['calorias_totales'],
                        pointColorMapper: (data, _) =>
                        data['calorias_totales'] > 0
                            ? Colors.blueAccent
                            : Colors.grey,
                        name: 'Consumidas',
                        dataLabelMapper: (data, _) =>
                        '${data['calorias_totales'].toStringAsFixed(0)} kcal',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        innerRadius: '50%',
                      ),
                      // Serie para calorías restantes
                      DoughnutSeries<Map<String, dynamic>, String>(
                        dataSource: chartData,
                        xValueMapper: (data, _) => 'Restante',
                        yValueMapper: (data, _) =>
                        (data['meta_calorias'] - data['calorias_totales']) >
                            0
                            ? (data['meta_calorias'] -
                            data['calorias_totales'])
                            : 0,
                        pointColorMapper: (data, _) => Colors.greenAccent,
                        name: 'Restante',
                        dataLabelMapper: (data, _) =>
                        '${(data['meta_calorias'] - data['calorias_totales']).toStringAsFixed(0)} kcal',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        innerRadius: '65%',
                      ),
                    ],
                  ),
                  // Texto central (calorías consumidas)
                  Positioned(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Consumidas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${caloriasConsumidas.toStringAsFixed(0)} kcal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón para mostrar el modal
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: Icon(FontAwesomeIcons.crosshairs, size: 30, color: Colors.redAccent),
                      onPressed: () {
                        final double metaCalorias = _stats.isNotEmpty
                            ? _stats[0]['meta_calorias']
                            : widget.caloriasObjetivo;
                        _showGoalModal(metaCalorias);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
