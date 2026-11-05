class Repuesto {
  final int? id;
  final String nombre;
  final String codigo;
  final double precio;
  final int stock;

  Repuesto({this.id, required this.nombre, required this.codigo, required this.precio, required this.stock});

  factory Repuesto.fromMap(Map<String, dynamic> map) => Repuesto(
    id: map['id'] as int?,
    nombre: map['nombre'] as String,
    codigo: map['codigo'] as String,
    precio: (map['precio'] as num).toDouble(),
    stock: map['stock'] as int,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'codigo': codigo,
    'precio': precio,
    'stock': stock,
  };
}