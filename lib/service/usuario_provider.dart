import 'package:flutter/material.dart';

class UsuarioProvider with ChangeNotifier {
  String? _telefono;
  Map<String, dynamic>? _datosUsuario;

  String? get telefono => _telefono;
  Map<String, dynamic>? get datosUsuario => _datosUsuario;

  void setTelefono(String telefono) {
    _telefono = telefono;
    print("Teléfono establecido en provider: $_telefono");
    notifyListeners();
  }

  void setDatosUsuario(Map<String, dynamic> datos) {
    _datosUsuario = datos;
    notifyListeners();
  }

  void limpiarDatos() {
    _telefono = null;
    _datosUsuario = null;
    notifyListeners();
  }
}