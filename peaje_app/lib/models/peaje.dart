class Peaje {
  final int id;
  final String peaje;
  final String placa;
  final String tarifa;
  final String fecha;
  final double precio;

  Peaje({
    required this.id,
    required this.peaje,
    required this.placa,
    required this.tarifa,
    required this.fecha,
    required this.precio,
  });

  factory Peaje.fromJson(Map<String, dynamic> json) {
    return Peaje(
      id: json['id'],
      peaje: json['nombrePeaje'],
      placa: json['placa'],
      tarifa: json['idCategoriaTarifa '],
      fecha: json['fechaRegistro'],
      precio: json['valor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peaje': peaje,
      'placa': placa,
      'tarifa': tarifa,
      'fecha': fecha,
      'precio': precio,
    };
  }
}
