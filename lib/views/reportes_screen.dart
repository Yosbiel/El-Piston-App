import 'package:flutter/material.dart';
import '../data/repositorio.dart';

class ReportesScreen extends StatefulWidget {
  final Repositorio repo;
  const ReportesScreen({super.key, required this.repo});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  Map<String, int> _carga = {};
  double _facturacionHoy = 0.0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();
    final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59).toIso8601String();
    final c = await widget.repo.obtenerCargaMecanicos();
    final f = await widget.repo.calcularFacturacion(inicio, fin);
    if (mounted) setState(() { _carga = c; _facturacionHoy = f; _cargando = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Facturación de hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('\$${_facturacionHoy.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Carga de trabajo por mecánico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._carga.entries.map((e) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(e.key),
              trailing: Text('${e.value} órdenes activas', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )),
          if (_carga.isEmpty) const Text('No hay mecánicos registrados', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}