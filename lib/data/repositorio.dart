import 'package:drift/drift.dart';
import '../models/cliente.dart';
import '../models/vehiculo.dart';
import '../models/orden.dart';
import '../models/trabajo.dart';
import '../models/repuesto.dart';
import 'database.dart';

/// Repositorio que centraliza todas las consultas SQL a la base de datos.
/// Aquí vive la lógica de negocio (validaciones, inserciones, etc.).
class Repositorio {
  final AppDatabase db;
  Repositorio(this.db);

  // --- CONFIGURACIÓN (TEMA) ---

  /// Lee el tema guardado (claro/oscuro) para que se mantenga al cerrar la app.
  Future<String?> obtenerTema() async {
    final res = await db.customSelect("SELECT valor FROM configuracion WHERE clave = 'tema'").getSingleOrNull();
    return res?.data['valor'] as String?;
  }

  /// Guarda el tema seleccionado por el usuario.
  Future<void> guardarTema(String tema) async {
    await db.customInsert(
      "INSERT OR REPLACE INTO configuracion (clave, valor) VALUES ('tema', ?)",
      variables: [Variable(tema)],
    );
  }

  // --- CLIENTES ---

  /// Devuelve todos los clientes registrados.
  Future<List<Cliente>> obtenerClientes() async {
    final res = await db.customSelect('SELECT * FROM clientes').get();
    return res.map((row) => Cliente.fromMap(row.data)).toList();
  }

  /// Inserta un nuevo cliente en la base de datos.
  Future<int> insertarCliente(Cliente c) async {
    return db.customInsert('INSERT INTO clientes (nombre, telefono, direccion) VALUES (?, ?, ?)',
        variables: [Variable(c.nombre), Variable(c.telefono), Variable(c.direccion)]);
  }

  /// Verifica si un teléfono ya existe (para evitar duplicados).
  Future<bool> existeTelefono(String telefono) async {
    final res = await db.customSelect('SELECT COUNT(*) as count FROM clientes WHERE telefono = ?', variables: [Variable(telefono)]).getSingle();
    return (res.data['count'] as int) > 0;
  }

  /// Elimina un cliente por su ID.
  Future<void> eliminarCliente(int id) async {
    await db.customUpdate('DELETE FROM clientes WHERE id = ?', variables: [Variable(id)]);
  }

  // --- VEHICULOS ---

  /// Devuelve todos los vehículos de un cliente específico.
  Future<List<Vehiculo>> obtenerVehiculosPorCliente(int clienteId) async {
    final res = await db.customSelect('SELECT * FROM vehiculos WHERE cliente_id = ?', variables: [Variable(clienteId)]).get();
    return res.map((row) => Vehiculo.fromMap(row.data)).toList();
  }

  /// Inserta un nuevo vehículo.
  Future<int> insertarVehiculo(Vehiculo v) async {
    return db.customInsert('INSERT INTO vehiculos (cliente_id, matricula, marca, modelo, anio, kilometraje) VALUES (?, ?, ?, ?, ?, ?)',
        variables: [Variable(v.clienteId), Variable(v.matricula), Variable(v.marca), Variable(v.modelo), Variable(v.anio), Variable(v.kilometraje)]);
  }

  /// Verifica si una matrícula ya existe (para evitar duplicados).
  Future<bool> existeMatricula(String matricula) async {
    final res = await db.customSelect('SELECT COUNT(*) as count FROM vehiculos WHERE matricula = ?', variables: [Variable(matricula)]).getSingle();
    return (res.data['count'] as int) > 0;
  }

  // --- ORDENES ---

  /// Devuelve todas las órdenes, ordenadas por fecha de entrada (la más reciente primero).
  Future<List<Orden>> obtenerOrdenes() async {
    final res = await db.customSelect('SELECT * FROM ordenes ORDER BY fecha_entrada DESC').get();
    return res.map((row) => Orden.fromMap(row.data)).toList();
  }

  /// Inserta una nueva orden de servicio.
  Future<int> insertarOrden(Orden o) async {
    return db.customInsert('INSERT INTO ordenes (vehiculo_id, mecanico_id, fecha_entrada, problema, estado) VALUES (?, ?, ?, ?, ?)',
        variables: [Variable(o.vehiculoId), Variable(o.mecanicoId), Variable(o.fechaEntrada), Variable(o.problema), Variable(o.estado)]);
  }

  /// Actualiza el estado de una orden (recibida, en reparación, entregada, etc.).
  Future<void> actualizarEstadoOrden(int ordenId, String nuevoEstado) async {
    await db.customUpdate('UPDATE ordenes SET estado = ? WHERE id = ?',
        variables: [Variable(nuevoEstado), Variable(ordenId)]);
  }

  /// Elimina una orden por su ID.
  Future<void> eliminarOrden(int id) async {
    await db.customUpdate('DELETE FROM ordenes WHERE id = ?', variables: [Variable(id)]);
  }

  // --- REPUESTOS ---

  /// Devuelve todos los repuestos del inventario.
  Future<List<Repuesto>> obtenerRepuestos() async {
    final res = await db.customSelect('SELECT * FROM repuestos').get();
    return res.map((row) => Repuesto.fromMap(row.data)).toList();
  }

  /// Inserta un nuevo repuesto.
  Future<void> insertarRepuesto(Repuesto r) async {
    await db.customInsert('INSERT INTO repuestos (nombre, codigo, precio, stock) VALUES (?, ?, ?, ?)',
        variables: [Variable(r.nombre), Variable(r.codigo), Variable(r.precio), Variable(r.stock)]);
  }

  /// Verifica si un código de repuesto ya existe (para evitar duplicados).
  Future<bool> existeCodigoRepuesto(String codigo) async {
    final res = await db.customSelect('SELECT COUNT(*) as count FROM repuestos WHERE codigo = ?', variables: [Variable(codigo)]).getSingle();
    return (res.data['count'] as int) > 0;
  }

  /// Elimina un repuesto por su ID.
  Future<void> eliminarRepuesto(int id) async {
    await db.customUpdate('DELETE FROM repuestos WHERE id = ?', variables: [Variable(id)]);
  }

  /// Registra el uso de un repuesto en una orden y resta stock del inventario.
  Future<void> usarRepuesto(int ordenId, int repuestoId, int cantidad) async {
    await db.customInsert('INSERT INTO repuestos_usados (orden_id, repuesto_id, cantidad) VALUES (?, ?, ?)',
        variables: [Variable(ordenId), Variable(repuestoId), Variable(cantidad)]);
    await db.customUpdate('UPDATE repuestos SET stock = stock - ? WHERE id = ?',
        variables: [Variable(cantidad), Variable(repuestoId)]);
  }

  /// Devuelve los repuestos con stock bajo (menos de 5 unidades).
  Future<List<Repuesto>> obtenerRepuestosBajos() async {
    final res = await db.customSelect('SELECT * FROM repuestos WHERE stock < 5').get();
    return res.map((row) => Repuesto.fromMap(row.data)).toList();
  }
}