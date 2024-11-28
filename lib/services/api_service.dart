import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.223:4000/users';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'correo_usuario': email, 'contraseña_usuario': password},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
      String firstName, String lastName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {
        'nombre_usuario': firstName,
        'apellido_usuario': lastName,
        'correo_usuario': email,
        'contraseña_usuario': password,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<void> updateProgress({
    required String token,
    required int caloriasConsumidas,
    required double caloriasObjetivo,
  }) async {
    if (caloriasConsumidas <= 0 || caloriasObjetivo <= 0) {
      throw Exception('Las calorías deben ser mayores a 0.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/progress'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'caloriasConsumidas': caloriasConsumidas,
        'caloriasObjetivo': caloriasObjetivo,
      }),
    );

    if (response.statusCode == 200) {
      print('Progreso actualizado: ${response.body}');
    } else {
      throw Exception('Error al actualizar progreso: ${response.body}');
    }
  }

}
