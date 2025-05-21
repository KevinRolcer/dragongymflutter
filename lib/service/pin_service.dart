import 'package:http/http.dart' as http;
import 'dart:convert';

class PinService {
  final String baseUrl = "https://kevinrolcer.com/dragongym/movil";

  Future<Map<String, dynamic>> buscarPin(String telefono) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/pin.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"Telefono": telefono}),
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

  Future<Map<String, dynamic>> actualizarPin(String telefono, int pin) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/pin.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "Telefono": telefono,
          "pin": pin.toString().padLeft(4, '0'),
        }),
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

  Future<Map<String, dynamic>> eliminarPin(String telefono) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/pin.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"Telefono": telefono}),
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
