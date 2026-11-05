class Trabajo {
  final int? id;
  final int ordenId;
  final String descripcion;
  final double precio;

  Trabajo({this.id, required this.ordenId, required this.descripcion, required this.precio});

  factory Trabajo.fromMap(Map<String, dynamic> map) => Trabajo(
    id: map['id'] as int?,
    ordenId: map['orden_id'] as int,
    descripcion: map['descripcion'] as String,
    precio: (map['precio'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'orden_id': ordenId,
    'descripcion': descripcion,
    'precio': precio,
  };
}