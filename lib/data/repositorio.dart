import 'package:drift/drift.dart';
import '../models/cliente.dart';
import '../models/vehiculo.dart';
import '../models/orden.dart';
import '../models/trabajo.dart';
import '../models/repuesto.dart';
import 'database.dart';

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

  // --- ORDENES ---
  Future<List<Orden>> obtenerOrdenes() async {
    final res = await db.customSelect('SELECT * FROM ordenes ORDER BY fecha_entrada DESC').get();
    return res.map((row) => Orden.fromMap(row.data)).toList();
  }

  Future<int> insertarOrden(Orden o) async {
    return db.customInsert('INSERT INTO ordenes (vehiculo_id, mecanico_id, fecha_entrada, problema, estado) VALUES (?, ?, ?, ?, ?)',
        variables: [Variable(o.vehiculoId), Variable(o.mecanicoId), Variable(o.fechaEntrada), Variable(o.problema), Variable(o.estado)]);
  }

  Future<void> actualizarEstadoOrden(int ordenId, String nuevoEstado) async {
    await db.customUpdate('UPDATE ordenes SET estado = ? WHERE id = ?',
        variables: [Variable(nuevoEstado), Variable(ordenId)]);
  }

  Future<void> eliminarOrden(int id) async {
    await db.customUpdate('DELETE FROM ordenes WHERE id = ?', variables: [Variable(id)]);
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

  Future<void> usarRepuesto(int ordenId, int repuestoId, int cantidad) async {
    await db.customInsert('INSERT INTO repuestos_usados (orden_id, repuesto_id, cantidad) VALUES (?, ?, ?)',
        variables: [Variable(ordenId), Variable(repuestoId), Variable(cantidad)]);
    await db.customUpdate('UPDATE repuestos SET stock = stock - ? WHERE id = ?',
        variables: [Variable(cantidad), Variable(repuestoId)]);
  }

  Future<List<Repuesto>> obtenerRepuestosBajos() async {
    final res = await db.customSelect('SELECT * FROM repuestos WHERE stock < 5').get();
    return res.map((row) => Repuesto.fromMap(row.data)).toList();
  }
}