class Orden {
  final int? id;
  final int vehiculoId;
  final int? mecanicoId;
  final String fechaEntrada;
  final String problema;
  final String estado;
  final double pagado; 

  Orden({
    this.id,
    required this.vehiculoId,
    this.mecanicoId,
    required this.fechaEntrada,
    required this.problema,
    required this.estado,
    this.pagado = 0.0,
  });

  factory Orden.fromMap(Map<String, dynamic> map) => Orden(
    id: map['id'] as int?,
    vehiculoId: map['vehiculo_id'] as int,
    mecanicoId: map['mecanico_id'] as int?,
    fechaEntrada: map['fecha_entrada'] as String,
    problema: map['problema'] as String,
    estado: map['estado'] as String,
    pagado: (map['pagado'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'vehiculo_id': vehiculoId,
    'mecanico_id': mecanicoId,
    'fecha_entrada': fechaEntrada,
    'problema': problema,
    'estado': estado,
    'pagado': pagado,
  };
}