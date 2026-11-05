import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/repuesto.dart';

class RepuestosScreen extends StatefulWidget {
  final Repositorio repo;
  const RepuestosScreen({super.key, required this.repo});

  @override
  State<RepuestosScreen> createState() => _RepuestosScreenState();
}

class _RepuestosScreenState extends State<RepuestosScreen> {
  List<Repuesto> _repuestos = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final data = await widget.repo.obtenerRepuestos();
    if (mounted) setState(() => _repuestos = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Repuestos')),
      body: _repuestos.isEmpty
          ? const Center(child: Text('No hay repuestos en inventario'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _repuestos.length,
              itemBuilder: (_, i) {
                final r = _repuestos[i];
                final stockBajo = r.stock < 5;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: stockBajo ? Colors.red : Colors.grey,
                    ),
                    title: Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Código: ${r.codigo} | Precio: \$${r.precio.toStringAsFixed(2)}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: stockBajo ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Stock: ${r.stock}',
                        style: TextStyle(
                          color: stockBajo ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}