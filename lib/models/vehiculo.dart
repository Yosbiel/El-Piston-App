class Vehiculo {
  final int? id;
  final int clienteId;
  final String matricula;
  final String marca;
  final String modelo;
  final int? anio;
  final int? kilometraje;

  Vehiculo({this.id, required this.clienteId, required this.matricula, required this.marca, required this.modelo, this.anio, this.kilometraje});

  factory Vehiculo.fromMap(Map<String, dynamic> map) => Vehiculo(
    id: map['id'] as int?,
    clienteId: map['cliente_id'] as int,
    matricula: map['matricula'] as String,
    marca: map['marca'] as String,
    modelo: map['modelo'] as String,
    anio: map['anio'] as int?,
    kilometraje: map['kilometraje'] as int?,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'cliente_id': clienteId,
    'matricula': matricula,
    'marca': marca,
    'modelo': modelo,
    'anio': anio,
    'kilometraje': kilometraje,
  };
}