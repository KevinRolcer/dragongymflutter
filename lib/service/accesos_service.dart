import 'package:http/http.dart' as http;
import 'dart:convert';

class AccesosService {
  final String baseUrl = "https://kevinrolcer.com/dragongym/movil";

  Future<Map<String, dynamic>> obtenerEstadoGimnasio() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/estadogym.php"),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "mensaje": "Error del servidor: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "mensaje": "Error de conexión: ${e.toString()}"
      };
    }
  }
}
