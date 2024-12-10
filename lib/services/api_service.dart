import 'dart:convert';
import 'dart:async'; // Para manejar TimeoutException
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.223:4000/users';

  // Método de inicio de sesión
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'correo_usuario': email, 'contraseña_usuario': password},
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en el inicio de sesión: $e');
    }
  }

  // Método de registro
  static Future<Map<String, dynamic>> register(
      String firstName,
      String lastName,
      String email,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {
          'nombre_usuario': firstName,
          'apellido_usuario': lastName,
          'correo_usuario': email,
          'contraseña_usuario': password,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en el registro: $e');
    }
  }

  // Actualizar progreso
  static Future<void> updateProgress({
    required String token,
    required int caloriasConsumidas,
    required double caloriasObjetivo,
  }) async {
    if (caloriasConsumidas <= 0 || caloriasObjetivo <= 0) {
      throw Exception('Las calorías deben ser mayores a 0.');
    }

    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/progress'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'caloriasConsumidas': caloriasConsumidas,
          'caloriasObjetivo': caloriasObjetivo,
        }),
      )
          .timeout(const Duration(seconds: 10));

      _handleResponse(response); // Verifica si hubo errores en la respuesta
      print('Progreso actualizado correctamente.');
    } catch (e) {
      throw Exception('Error al actualizar progreso: $e');
    }
  }

  // Método común para manejar respuestas
  static dynamic _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Respuesta exitosa
        return jsonDecode(response.body);
      } else {
        // Respuesta con error
        final errorData = jsonDecode(response.body);
        throw Exception('Error (${response.statusCode}): ${errorData['message'] ?? 'Desconocido'}');
      }
    } on FormatException {
      throw Exception('Respuesta no válida del servidor: ${response.body}');
    } catch (e) {
      throw Exception('Error procesando la respuesta: $e');
    }
  }
}
