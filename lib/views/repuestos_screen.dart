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

  void _mostrarFormulario() {
    final nombreCtrl = TextEditingController();
    final codigoCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Repuesto'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codigoCtrl,
                  decoration: const InputDecoration(labelText: 'Código *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: precioCtrl,
                  decoration: const InputDecoration(labelText: 'Precio (\$) *', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                    if (double.tryParse(v) == null) return 'Debe ser un número';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock inicial *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                    if (int.tryParse(v) == null) return 'Debe ser un entero';
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
                await widget.repo.insertarRepuesto(Repuesto(
                  nombre: nombreCtrl.text.trim(),
                  codigo: codigoCtrl.text.trim(),
                  precio: double.parse(precioCtrl.text.trim()),
                  stock: int.parse(stockCtrl.text.trim()),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
                _mostrarToast('Repuesto guardado con éxito');
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
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }
}