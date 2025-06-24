import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../service/pago_service.dart';
import 'package:provider/provider.dart';
import '../service/usuario_provider.dart';
import '../values/app_colors.dart';
import '../service/perfil_service.dart';


class PagoScreen extends StatefulWidget {
  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  File? _imagen;
  bool _subiendo = false;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _imagen = File(pickedFile.path));
    }
  }

  Future<void> _subirComprobante() async {
    if (_imagen == null) return;

    final telefono = Provider.of<UsuarioProvider>(context, listen: false).telefono;
    if (telefono == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teléfono no disponible')),
      );
      return;
    }

    setState(() => _subiendo = true);

    // Obtener el ID_Miembro desde el servicio
    final perfilResp = await PerfilService().obtenerPerfilPorTelefono(telefono);
    if (perfilResp['success'] != true || perfilResp['perfil'] == null) {
      setState(() => _subiendo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener el ID del miembro')),
      );
      return;
    }

    final idMiembro = perfilResp['perfil']['ID_Miembro'].toString();

    final respuesta = await PagoService().subirComprobante(
      idMiembro: idMiembro,
      imagen: _imagen!,
    );

    setState(() => _subiendo = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(respuesta['mensaje']),
      backgroundColor: respuesta['success'] ? Colors.green : Colors.red,
    ));

    if (respuesta['success']) {
      setState(() => _imagen = null);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkMode,
      appBar: AppBar(
        backgroundColor: AppColors.blackBack,
        title: Text("Subir Comprobante", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_imagen != null)
              Image.file(_imagen!, height: 200),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _seleccionarImagen,
              icon: Icon(Icons.upload_file),
              label: Text("Subir comprobante"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (_imagen != null)
              ElevatedButton(
                onPressed: _subiendo ? null : _subirComprobante,
                child: _subiendo ? CircularProgressIndicator(color: Colors.white) : Text("Enviar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}