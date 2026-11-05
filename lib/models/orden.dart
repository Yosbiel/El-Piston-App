class Orden {
  final int? id;
  final int vehiculoId;
  final int? mecanicoId;
  final String fechaEntrada;
  final String problema;
  final String estado; // recibida, en_diagnostico, en_reparacion, lista, entregada, cancelada

  Orden({this.id, required this.vehiculoId, this.mecanicoId, required this.fechaEntrada, required this.problema, required this.estado});

  factory Orden.fromMap(Map<String, dynamic> map) => Orden(
    id: map['id'] as int?,
    vehiculoId: map['vehiculo_id'] as int,
    mecanicoId: map['mecanico_id'] as int?,
    fechaEntrada: map['fecha_entrada'] as String,
    problema: map['problema'] as String,
    estado: map['estado'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'vehiculo_id': vehiculoId,
    'mecanico_id': mecanicoId,
    'fecha_entrada': fechaEntrada,
    'problema': problema,
    'estado': estado,
  };
}