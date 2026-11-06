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

  void _mostrarToast(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(esError ? Icons.error : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: esError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
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

  void _mostrarFormulario() {
    final vehiculoCtrl = TextEditingController();
    final problemaCtrl = TextEditingController();
    String estadoSeleccionado = 'recibida';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Orden'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: vehiculoCtrl,
                  decoration: const InputDecoration(labelText: 'ID del Vehículo *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                    if (int.tryParse(v) == null) return 'Debe ser un número';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: problemaCtrl,
                  decoration: const InputDecoration(labelText: 'Problema reportado *', border: OutlineInputBorder()),
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: estadoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'recibida', child: Text('Recibida')),
                    DropdownMenuItem(value: 'en_diagnostico', child: Text('En diagnóstico')),
                    DropdownMenuItem(value: 'en_reparacion', child: Text('En reparación')),
                    DropdownMenuItem(value: 'lista', child: Text('Lista para entregar')),
                    DropdownMenuItem(value: 'entregada', child: Text('Entregada')),
                    DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                  ],
                  onChanged: (val) {
                    if (val != null) estadoSeleccionado = val;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await widget.repo.insertarOrden(Orden(
                  vehiculoId: int.parse(vehiculoCtrl.text.trim()),
                  fechaEntrada: DateTime.now().toIso8601String(),
                  problema: problemaCtrl.text.trim(),
                  estado: estadoSeleccionado,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
                _mostrarToast('Orden creada con éxito');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }
}