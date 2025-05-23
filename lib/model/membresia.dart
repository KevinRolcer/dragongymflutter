class Membresia{
  final String idMiembro;
  final String fechaInicio;
  final String fechaFin;
  final String fechaPago;
  final String idMembresia;

  Membresia({
    required this.idMiembro,
    required this.fechaInicio,
    required this.fechaFin,
    required this.fechaPago,
    required this.idMembresia,
  });

  factory Membresia.fromJson(Map<String, dynamic> json) {
    return Membresia(
      idMiembro: json['ID_Miembro'].toString(),
      fechaInicio: json['FechaInicio'].toString(),
      fechaFin: json['FechaFin'].toString(),
      fechaPago: json['FechaPago'].toString(),
      idMembresia: json['ID_Membresia'].toString(),
    );
  }
}
