import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/repuesto.dart';
import '../widgets/animaciones.dart';
import '../utils/toast.dart';

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

  void _eliminar(Repuesto r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar repuesto?'),
        content: Text('Se eliminará ${r.nombre} permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.repo.eliminarRepuesto(r.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _cargar();
              mostrarToast(context, 'Repuesto eliminado');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFormulario() {
    final nombreCtrl = TextEditingController();
    final codigoCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? _errorCodigo;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: const Text('Nuevo Repuesto'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreCtrl,
                        maxLength: 60,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          border: OutlineInputBorder(),
                          counterStyle: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: codigoCtrl,
                        maxLength: 20,
                        decoration: InputDecoration(
                          labelText: 'Código *',
                          border: const OutlineInputBorder(),
                          errorText: _errorCodigo,
                          counterStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: precioCtrl,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: 'Precio (\$) *',
                          border: OutlineInputBorder(),
                          counterStyle: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          if (double.tryParse(v) == null) return 'Debe ser un número';
                          if (double.parse(v) < 0) return 'Debe ser positivo';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: stockCtrl,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Stock inicial *',
                          border: OutlineInputBorder(),
                          counterStyle: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          if (int.tryParse(v) == null) return 'Debe ser un entero';
                          if (int.parse(v) < 0) return 'Debe ser positivo';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final codigo = codigoCtrl.text.trim();
                    if (await widget.repo.existeCodigoRepuesto(codigo)) {
                      setStateDialog(() => _errorCodigo = 'Ese código ya está registrado');
                      return;
                    }
                    setStateDialog(() => _errorCodigo = null);
                    await widget.repo.insertarRepuesto(Repuesto(
                      nombre: nombreCtrl.text.trim(),
                      codigo: codigo,
                      precio: double.parse(precioCtrl.text.trim()),
                      stock: int.parse(stockCtrl.text.trim()),
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    _cargar();
                    mostrarToast(context, 'Repuesto guardado con éxito');
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _repuestos.isEmpty
          ? const AnimatedEmptyText(texto: 'No hay repuestos en inventario')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _repuestos.length,
              itemBuilder: (_, i) {
                final r = _repuestos[i];
                final stockBajo = r.stock < 5;
                return AnimatedCard(
                  index: i,
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.settings, color: stockBajo ? Colors.red : Colors.grey),
                      title: Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Código: ${r.codigo} | Precio: \$${r.precio.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: stockBajo ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Stock: ${r.stock}',
                              style: TextStyle(color: stockBajo ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _eliminar(r),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: AnimatedFab(onPressed: _mostrarFormulario),
    );
  }
}