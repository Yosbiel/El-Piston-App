import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AppDatabase extends GeneratedDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  // Hacemos el método público para poder llamarlo desde main.dart
  static QueryExecutor openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'piston.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => [];
  @override
  int get schemaVersion => 1;

  Future<void> crearTablas() async {
    await customStatement('''CREATE TABLE IF NOT EXISTS clientes (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL, telefono TEXT NOT NULL, direccion TEXT)''');
    await customStatement('''CREATE TABLE IF NOT EXISTS vehiculos (id INTEGER PRIMARY KEY AUTOINCREMENT, cliente_id INTEGER NOT NULL, matricula TEXT NOT NULL, marca TEXT NOT NULL, modelo TEXT NOT NULL, anio INTEGER, kilometraje INTEGER, FOREIGN KEY (cliente_id) REFERENCES clientes (id))''');
    await customStatement('''CREATE TABLE IF NOT EXISTS mecanicos (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL)''');
    await customStatement('''CREATE TABLE IF NOT EXISTS ordenes (id INTEGER PRIMARY KEY AUTOINCREMENT, vehiculo_id INTEGER NOT NULL, mecanico_id INTEGER, fecha_entrada TEXT NOT NULL, problema TEXT NOT NULL, estado TEXT NOT NULL DEFAULT 'recibida', FOREIGN KEY (vehiculo_id) REFERENCES vehiculos (id), FOREIGN KEY (mecanico_id) REFERENCES mecanicos (id))''');
    await customStatement('''CREATE TABLE IF NOT EXISTS trabajos (id INTEGER PRIMARY KEY AUTOINCREMENT, orden_id INTEGER NOT NULL, descripcion TEXT NOT NULL, precio REAL NOT NULL, FOREIGN KEY (orden_id) REFERENCES ordenes (id))''');
    await customStatement('''CREATE TABLE IF NOT EXISTS repuestos (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL, codigo TEXT NOT NULL, precio REAL NOT NULL, stock INTEGER NOT NULL DEFAULT 0)''');
    await customStatement('''CREATE TABLE IF NOT EXISTS repuestos_usados (id INTEGER PRIMARY KEY AUTOINCREMENT, orden_id INTEGER NOT NULL, repuesto_id INTEGER NOT NULL, cantidad INTEGER NOT NULL, FOREIGN KEY (orden_id) REFERENCES ordenes (id), FOREIGN KEY (repuesto_id) REFERENCES repuestos (id))''');
  }
}