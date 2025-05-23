class Perfil {
  final String idMiembro;
  final String nombre;
  final String apellidoP;
  final String apellidoM;
  final String sexo;
  final String telefono;
  final String estatus;
  final String pin;

  Perfil({
    required this.idMiembro,
    required this.nombre,
    required this.apellidoP,
    required this.apellidoM,
    required this.sexo,
    required this.telefono,
    required this.estatus,
    required this.pin,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      idMiembro: json['ID_Miembro'].toString(),
      nombre: json['Nombre'].toString(),
      apellidoP: json['ApellidoP'].toString(),
      apellidoM: json['ApellidoM'].toString(),
      sexo: json['Sexo'].toString(),
      telefono: json['Telefono'].toString(),
      estatus: json['Estatus'].toString(),
      pin: json['pin'].toString(),
    );
  }
}
