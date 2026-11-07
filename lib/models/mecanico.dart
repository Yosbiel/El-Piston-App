/// Modelo que representa a un mecánico del taller.
class Mecanico {
  final int? id;
  final String nombre;

  Mecanico({this.id, required this.nombre});

  factory Mecanico.fromMap(Map<String, dynamic> map) => Mecanico(
    id: map['id'] as int?,
    nombre: map['nombre'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
  };
}