class Planes {
  final String idMembresia;
  final String tipo;
  final String descripcion;
  final double costo;
  final String duracion;

  Planes({
    required this.idMembresia,
    required this.tipo,
    required this.descripcion,
    required this.costo,
    required this.duracion,
  });

  factory Planes.fromJson(Map<String, dynamic> json) {
    return Planes(
      idMembresia: json['ID_Membresia'].toString(),
      tipo: json['Tipo'] ?? '',
      descripcion: json['Descripcion'] ?? '',
      costo: double.tryParse(json['Costo'].toString()) ?? 0.0,
      duracion: json['Duracion'] ?? '',
    );
  }
}
