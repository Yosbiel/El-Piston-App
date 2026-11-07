/// Modelo que representa a un mecánico del taller.
class Mecanico {
  final int? id;
  final String nombre;
  final String rol;

  Mecanico({this.id, required this.nombre, required this.rol});

  factory Mecanico.fromMap(Map<String, dynamic> map) => Mecanico(
    id: map['id'] as int?,
    nombre: map['nombre'] as String,
    rol: map['rol'] as String? ?? 'General',
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'rol': rol,
  };
}