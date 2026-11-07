import 'package:drift/drift.dart';
import '../models/cliente.dart';
import '../models/vehiculo.dart';
import '../models/mecanico.dart';
import '../models/orden.dart';
import '../models/trabajo.dart';
import '../models/repuesto.dart';
import 'database.dart';

/// Repositorio que centraliza todas las consultas SQL a la base de datos.
class Repositorio {
  final AppDatabase db;
  Repositorio(this.db);

  // --- CONFIGURACIÓN (TEMA) ---
  Future<String?> obtenerTema() async {
    final res = await db.customSelect("SELECT valor FROM configuracion WHERE clave = 'tema'").getSingleOrNull();
    return res?.data['valor'] as String?;
  }

  Future<void> guardarTema(String tema) async {
    await db.customInsert(
      "INSERT OR REPLACE INTO configuracion (clave, valor) VALUES ('tema', ?)",
      variables: [Variable(tema)],
    );
  }

  // --- CLIENTES ---
  Future<List<Cliente>> obtenerClientes() async {
    final res = await db.customSelect('SELECT * FROM clientes').get();
    return res.map((row) => Cliente.fromMap(row.data)).toList();
  }

  Future<int> insertarCliente(Cliente c) async {
    return db.customInsert('INSERT INTO clientes (nombre, telefono, direccion) VALUES (?, ?, ?)',
        variables: [Variable(c.nombre), Variable(c.telefono), Variable(c.direccion)]);
  }

  Future<bool> existeTelefono(String telefono) async {
    final res = await db.customSelect('SELECT COUNT(*) as count FROM clientes WHERE telefono = ?', variables: [Variable(telefono)]).getSingle();
    return (res.data['count'] as int) > 0;
  }

  Future<void> eliminarCliente(int id) async {
    await db.customUpdate('DELETE FROM clientes WHERE id = ?', variables: [Variable(id)]);
  }

  // --- VEHICULOS ---
  Future<List<Vehiculo>> obtenerVehiculos() async {
    final res = await db.customSelect('SELECT * FROM vehiculos').get();
    return res.map((row) => Vehiculo.fromMap(row.data)).toList();
  }

  Future<List<Vehiculo>> obtenerVehiculosPorCliente(int clienteId) async {
    final res = await db.customSelect('SELECT * FROM vehiculos WHERE cliente_id = ?', variables: [Variable(clienteId)]).get();
    return res.map((row) => Vehiculo.fromMap(row.data)).toList();
  }

  Future<int> insertarVehiculo(Vehiculo v) async {
    return db.customInsert('INSERT INTO vehiculos (cliente_id, matricula, marca, modelo, anio, kilometraje) VALUES (?, ?, ?, ?, ?, ?)',
        variables: [Variable(v.clienteId), Variable(v.matricula), Variable(v.marca), Variable(v.modelo), Variable(v.anio), Variable(v.kilometraje)]);
  }

  Future<bool> existeMatricula(String matricula) async {
    final res = await db.customSelect('SELECT COUNT(*) as count FROM vehiculos WHERE matricula = ?', variables: [Variable(matricula)]).getSingle();
    return (res.data['count'] as int) > 0;
  }

  Future<void> eliminarVehiculo(int id) async {
    await db.customUpdate('DELETE FROM vehiculos WHERE id = ?', variables: [Variable(id)]);
  }

  // --- MECANICOS ---
  Future<List<Mecanico>> obtenerMecanicos() async {
    final res = await db.customSelect('SELECT * FROM mecanicos').get();
    return res.map((row) => Mecanico.fromMap(row.data)).toList();
  }

  Future<int> insertarMecanico(Mecanico m) async {
    return db.customInsert('INSERT INTO mecanicos (nombre) VALUES (?)',
        variables: [Variable(m.nombre)]);
  }

  Future<bool> existeMecanico(String nombre) async {
    final res = await db.customSelect('SELECT COUNT(*) as count FROM mecanicos WHERE nombre = ?', variables: [Variable(nombre)]).getSingle();
    return (res.data['count'] as int) > 0;
  }

  Future<void> eliminarMecanico(int id) async {
    await db.customUpdate('DELETE FROM mecanicos WHERE id = ?', variables: [Variable(id)]);
  }

  // --- ORDENES ---
  Future<List<Orden>> obtenerOrdenes() async {
    final res = await db.customSelect('SELECT * FROM ordenes ORDER BY fecha_entrada DESC').get();
    return res.map((row) => Orden.fromMap(row.data)).toList();
  }

  Future<Orden?> obtenerOrdenPorId(int id) async {
    final res = await db.customSelect('SELECT * FROM ordenes WHERE id = ?', variables: [Variable(id)]).getSingleOrNull();
    return res != null ? Orden.fromMap(res.data) : null;
  }

  Future<int> insertarOrden(Orden o) async {
    return db.customInsert('INSERT INTO ordenes (vehiculo_id, mecanico_id, fecha_entrada, problema, estado, pagado) VALUES (?, ?, ?, ?, ?, ?)',
        variables: [Variable(o.vehiculoId), Variable(o.mecanicoId), Variable(o.fechaEntrada), Variable(o.problema), Variable(o.estado), Variable(o.pagado)]);
  }

  Future<void> actualizarEstadoOrden(int ordenId, String nuevoEstado) async {
    await db.customUpdate('UPDATE ordenes SET estado = ? WHERE id = ?',
        variables: [Variable(nuevoEstado), Variable(ordenId)]);
  }

  Future<void> actualizarPagoOrden(int ordenId, double nuevoPagado) async {
    await db.customUpdate('UPDATE ordenes SET pagado = ? WHERE id = ?',
        variables: [Variable(nuevoPagado), Variable(ordenId)]);
  }

  Future<void> eliminarOrden(int id) async {
    await db.customUpdate('DELETE FROM ordenes WHERE id = ?', variables: [Variable(id)]);
  }

  // --- TRABAJOS ---
  Future<List<Trabajo>> obtenerTrabajosPorOrden(int ordenId) async {
    final res = await db.customSelect('SELECT * FROM trabajos WHERE orden_id = ?', variables: [Variable(ordenId)]).get();
    return res.map((row) => Trabajo.fromMap(row.data)).toList();
  }

  Future<void> insertarTrabajo(Trabajo t) async {
    await db.customInsert('INSERT INTO trabajos (orden_id, descripcion, precio) VALUES (?, ?, ?)',
        variables: [Variable(t.ordenId), Variable(t.descripcion), Variable(t.precio)]);
  }

  Future<void> eliminarTrabajo(int id) async {
    await db.customUpdate('DELETE FROM trabajos WHERE id = ?', variables: [Variable(id)]);
  }

  // --- REPUESTOS ---
  Future<List<Repuesto>> obtenerRepuestos() async {
    final res = await db.customSelect('SELECT * FROM repuestos').get();
    return res.map((row) => Repuesto.fromMap(row.data)).toList();
  }

  Future<void> insertarRepuesto(Repuesto r) async {
    await db.customInsert('INSERT INTO repuestos (nombre, codigo, precio, stock) VALUES (?, ?, ?, ?)',
        variables: [Variable(r.nombre), Variable(r.codigo), Variable(r.precio), Variable(r.stock)]);
  }

  Future<bool> existeCodigoRepuesto(String codigo) async {
    final res = await db.customSelect('SELECT COUNT(*) as count FROM repuestos WHERE codigo = ?', variables: [Variable(codigo)]).getSingle();
    return (res.data['count'] as int) > 0;
  }

  Future<void> eliminarRepuesto(int id) async {
    await db.customUpdate('DELETE FROM repuestos WHERE id = ?', variables: [Variable(id)]);
  }

  Future<List<Repuesto>> obtenerRepuestosBajos() async {
    final res = await db.customSelect('SELECT * FROM repuestos WHERE stock < 5').get();
    return res.map((row) => Repuesto.fromMap(row.data)).toList();
  }

  // --- REPUESTOS USADOS ---
  Future<void> usarRepuesto(int ordenId, int repuestoId, int cantidad) async {
    await db.customInsert('INSERT INTO repuestos_usados (orden_id, repuesto_id, cantidad) VALUES (?, ?, ?)',
        variables: [Variable(ordenId), Variable(repuestoId), Variable(cantidad)]);
    await db.customUpdate('UPDATE repuestos SET stock = stock - ? WHERE id = ?',
        variables: [Variable(cantidad), Variable(repuestoId)]);
  }

  Future<double> calcularCostoRepuestos(int ordenId) async {
    final res = await db.customSelect('''
      SELECT SUM(r.precio * ru.cantidad) as total
      FROM repuestos_usados ru
      JOIN repuestos r ON ru.repuesto_id = r.id
      WHERE ru.orden_id = ?
    ''', variables: [Variable(ordenId)]).getSingle();
    return (res.data['total'] as num?)?.toDouble() ?? 0.0;
  }

  // --- REPORTES ---
  Future<double> calcularTotalTrabajos(int ordenId) async {
    final res = await db.customSelect('SELECT SUM(precio) as total FROM trabajos WHERE orden_id = ?', variables: [Variable(ordenId)]).getSingle();
    return (res.data['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> calcularFacturacion(String fechaInicio, String fechaFin) async {
    // Suma de trabajos y repuestos de órdenes entregadas en un rango de fechas
    final res = await db.customSelect('''
      SELECT 
        (SELECT COALESCE(SUM(t.precio), 0) FROM trabajos t JOIN ordenes o ON t.orden_id = o.id WHERE o.fecha_entrada BETWEEN ? AND ? AND o.estado = 'entregada') +
        (SELECT COALESCE(SUM(r.precio * ru.cantidad), 0) FROM repuestos_usados ru JOIN repuestos r ON ru.repuesto_id = r.id JOIN ordenes o ON ru.orden_id = o.id WHERE o.fecha_entrada BETWEEN ? AND ? AND o.estado = 'entregada')
      as total
    ''', variables: [Variable(fechaInicio), Variable(fechaFin), Variable(fechaInicio), Variable(fechaFin)]).getSingle();
    return (res.data['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, int>> obtenerCargaMecanicos() async {
    final res = await db.customSelect('''
      SELECT m.nombre, COUNT(o.id) as cantidad
      FROM mecanicos m
      LEFT JOIN ordenes o ON o.mecanico_id = m.id AND o.estado != 'entregada' AND o.estado != 'cancelada'
      GROUP BY m.id
    ''').get();
    final Map<String, int> carga = {};
    for (var row in res) {
      carga[row.data['nombre'] as String] = row.data['cantidad'] as int;
    }
    return carga;
  }
}