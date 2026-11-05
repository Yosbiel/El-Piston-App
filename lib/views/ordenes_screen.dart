import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/orden.dart';

class OrdenesScreen extends StatefulWidget {
  final Repositorio repo;
  const OrdenesScreen({super.key, required this.repo});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  List<Orden> _ordenes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final data = await widget.repo.obtenerOrdenes();
    if (mounted) setState(() => _ordenes = data);
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'recibida': return Colors.blue;
      case 'en_diagnostico': return Colors.orange;
      case 'en_reparacion': return Colors.purple;
      case 'lista': return Colors.green;
      case 'entregada': return Colors.grey;
      case 'cancelada': return Colors.red;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes de Servicio')),
      body: _ordenes.isEmpty
          ? const Center(child: Text('No hay órdenes registradas'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _ordenes.length,
              itemBuilder: (_, i) {
                final o = _ordenes[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _colorEstado(o.estado).withOpacity(0.2),
                      child: Icon(Icons.build, color: _colorEstado(o.estado)),
                    ),
                    title: Text('Orden #${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Vehículo ID: ${o.vehiculoId}\n${o.problema}'),
                    trailing: Chip(
                      label: Text(o.estado, style: TextStyle(fontSize: 10, color: _colorEstado(o.estado))),
                      backgroundColor: _colorEstado(o.estado).withOpacity(0.1),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}