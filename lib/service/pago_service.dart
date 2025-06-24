import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

class PagoService {
  final String baseUrl = "https://kevinrolcer.com/dragongym/movil";

  Future<Map<String, dynamic>> subirComprobante({
    required String idMiembro,
    required File imagen,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/pago_subir.php"),
      );

      request.fields['ID_Miembro'] = idMiembro;
      request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path, filename: basename(imagen.path)));

      final response = await request.send();
      final respuestaString = await response.stream.bytesToString();

      return jsonDecode(respuestaString);
    } catch (e) {
      return {"success": false, "mensaje": "Error de conexión: ${e.toString()}"};
    }
  }
}