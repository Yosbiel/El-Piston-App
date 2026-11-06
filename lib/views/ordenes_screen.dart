import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/orden.dart';
import '../widgets/animaciones.dart';
import '../utils/toast.dart';

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

  void _eliminar(Orden o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar orden?'),
        content: Text('Se eliminará la orden #${o.id} permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.repo.eliminarOrden(o.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _cargar();
              mostrarToast(context, 'Orden eliminada');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFormulario() {
    final vehiculoCtrl = TextEditingController();
    final problemaCtrl = TextEditingController();
    String estadoSeleccionado = 'recibida';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text('Nueva Orden'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: vehiculoCtrl,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'ID del Vehículo *',
                    border: OutlineInputBorder(),
                    counterStyle: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                    if (int.tryParse(v) == null) return 'Debe ser un número';
                    if (int.parse(v) <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: problemaCtrl,
                  maxLength: 200,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Problema reportado *',
                    border: OutlineInputBorder(),
                    counterStyle: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 8),
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
                mostrarToast(context, 'Orden creada con éxito');
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
          ? const AnimatedEmptyText(texto: 'No hay órdenes registradas')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _ordenes.length,
              itemBuilder: (_, i) {
                final o = _ordenes[i];
                return AnimatedCard(
                  index: i,
                  child: _OrdenCard(
                    orden: o,
                    colorEstado: _colorEstado(o.estado),
                    onEliminar: () => _eliminar(o),
                  ),
                );
              },
            ),
      floatingActionButton: AnimatedFab(onPressed: _mostrarFormulario),
    );
  }
}

class _OrdenCard extends StatefulWidget {
  final Orden orden;
  final Color colorEstado;
  final VoidCallback onEliminar;

  const _OrdenCard({required this.orden, required this.colorEstado, required this.onEliminar});

  @override
  State<_OrdenCard> createState() => _OrdenCardState();
}

class _OrdenCardState extends State<_OrdenCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: widget.colorEstado.withOpacity(0.2),
                  child: Icon(Icons.build, color: widget.colorEstado, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Orden #${widget.orden.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.orden.estado.replaceAll('_', ' '),
                    style: TextStyle(fontSize: 10, color: widget.colorEstado, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: widget.onEliminar,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Vehículo ID: ${widget.orden.vehiculoId}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            LayoutBuilder(
              builder: (context, constraints) {
                final textStyle = const TextStyle(fontSize: 13);
                final textSpan = TextSpan(text: widget.orden.problema, style: textStyle);
                final tp = TextPainter(text: textSpan, maxLines: 2, textDirection: TextDirection.ltr);
                tp.layout(maxWidth: constraints.maxWidth);
                final excede = tp.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.orden.problema,
                      maxLines: _expandido ? null : 2,
                      overflow: _expandido ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                    if (excede)
                      GestureDetector(
                        onTap: () => setState(() => _expandido = !_expandido),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _expandido ? 'Leer menos' : '...Leer más',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}