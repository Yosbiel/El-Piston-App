import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/orden.dart';
import '../models/trabajo.dart';
import '../models/repuesto.dart';
import '../utils/toast.dart';

class DetalleOrdenScreen extends StatefulWidget {
  final Repositorio repo;
  final int ordenId;
  const DetalleOrdenScreen({super.key, required this.repo, required this.ordenId});

  @override
  State<DetalleOrdenScreen> createState() => _DetalleOrdenScreenState();
}

class _DetalleOrdenScreenState extends State<DetalleOrdenScreen> {
  Orden? _orden;
  List<Trabajo> _trabajos = [];
  List<Repuesto> _repuestos = [];
  double _costoRepuestos = 0.0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final o = await widget.repo.obtenerOrdenPorId(widget.ordenId);
    final t = await widget.repo.obtenerTrabajosPorOrden(widget.ordenId);
    final r = await widget.repo.obtenerRepuestos();
    final c = await widget.repo.calcularCostoRepuestos(widget.ordenId);
    if (mounted) setState(() { _orden = o; _trabajos = t; _repuestos = r; _costoRepuestos = c; });
  }

  double get _totalTrabajos => _trabajos.fold(0.0, (s, t) => s + t.precio);
  double get _totalGeneral => _totalTrabajos + _costoRepuestos;
  double get _saldoPendiente => _totalGeneral - (_orden?.pagado ?? 0.0);

  void _agregarTrabajo() {
    final descCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Trabajo'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descCtrl,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Descripción *', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: precioCtrl,
                  maxLength: 10,
                  decoration: const InputDecoration(labelText: 'Precio *', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Inválido' : null,
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
                await widget.repo.insertarTrabajo(Trabajo(ordenId: widget.ordenId, descripcion: descCtrl.text.trim(), precio: double.parse(precioCtrl.text.trim())));
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
                mostrarToast(context, 'Trabajo agregado');
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _agregarRepuesto() {
    if (_repuestos.isEmpty) {
      mostrarToast(context, 'No hay repuestos en inventario', esError: true);
      return;
    }

    int? repuestoId = _repuestos.first.id;
    final cantCtrl = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Usar Repuesto'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: repuestoId,
                      decoration: const InputDecoration(labelText: 'Repuesto', border: OutlineInputBorder()),
                      items: _repuestos.map((r) => DropdownMenuItem(value: r.id, child: Text('${r.nombre} (Stock: ${r.stock})'))).toList(),
                      onChanged: (v) => setStateDialog(() => repuestoId = v),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: cantCtrl,
                      maxLength: 4,
                      decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Inválido';
                        final rep = _repuestos.firstWhere((r) => r.id == repuestoId);
                        if (n > rep.stock) return 'Stock insuficiente';
                        return null;
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
                    await widget.repo.usarRepuesto(widget.ordenId, repuestoId!, int.parse(cantCtrl.text.trim()));
                    if (ctx.mounted) Navigator.pop(ctx);
                    _cargar();
                    mostrarToast(context, 'Repuesto usado');
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _registrarPago() {
    final montoCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar Pago'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Saldo pendiente: \$${_saldoPendiente.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: montoCtrl,
                  maxLength: 10,
                  decoration: const InputDecoration(labelText: 'Monto a pagar *', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Inválido';
                    if (n > _saldoPendiente) return 'Excede el saldo';
                    return null;
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
                final nuevoPagado = (_orden?.pagado ?? 0.0) + double.parse(montoCtrl.text.trim());
                await widget.repo.actualizarPagoOrden(widget.ordenId, nuevoPagado);
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
                mostrarToast(context, 'Pago registrado');
              }
            },
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_orden == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('Orden #${_orden!.id}')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              title: Text('Vehículo ID: ${_orden!.vehiculoId}'),
              subtitle: Text('Estado: ${_orden!.estado.replaceAll('_', ' ')}\nProblema: ${_orden!.problema}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Trabajos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(icon: const Icon(Icons.add), label: const Text('Agregar'), onPressed: _agregarTrabajo),
          ]),
          ..._trabajos.map((t) => ListTile(
            dense: true,
            title: Text(t.descripcion),
            trailing: Text('\$${t.precio.toStringAsFixed(2)}'),
          )),
          if (_trabajos.isEmpty) const Text('Sin trabajos registrados', style: TextStyle(color: Colors.grey)),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Repuestos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(icon: const Icon(Icons.add), label: const Text('Usar'), onPressed: _agregarRepuesto),
          ]),
          ListTile(dense: true, title: const Text('Costo de repuestos'), trailing: Text('\$${_costoRepuestos.toStringAsFixed(2)}')),
          const Divider(),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:'), Text('\$${_totalGeneral.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Pagado:'), Text('\$${(_orden?.pagado ?? 0).toStringAsFixed(2)}')]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Saldo:', style: TextStyle(fontWeight: FontWeight.bold)), Text('\$${_saldoPendiente.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('Registrar Pago'),
            onPressed: _saldoPendiente > 0 ? _registrarPago : null,
          ),
        ],
      ),
    );
  }
}