import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/cliente.dart';

class ClientesScreen extends StatefulWidget {
  final Repositorio repo;
  const ClientesScreen({super.key, required this.repo});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Cliente> _clientes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final data = await widget.repo.obtenerClientes();
    if (mounted) setState(() => _clientes = data);
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
    final telefonoCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'El teléfono es obligatorio';
                    if (v.length < 8) return 'Mínimo 8 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: direccionCtrl,
                  decoration: const InputDecoration(labelText: 'Dirección (opcional)', border: OutlineInputBorder()),
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
                await widget.repo.insertarCliente(Cliente(
                  nombre: nombreCtrl.text.trim(),
                  telefono: telefonoCtrl.text.trim(),
                  direccion: direccionCtrl.text.trim().isEmpty ? null : direccionCtrl.text.trim(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
                _mostrarToast('Cliente guardado con éxito');
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
      body: _clientes.isEmpty
          ? const Center(child: Text('No hay clientes registrados'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _clientes.length,
              itemBuilder: (_, i) {
                final c = _clientes[i];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(c.nombre[0].toUpperCase()),
                    ),
                    title: Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${c.telefono}${c.direccion != null ? '\n${c.direccion}' : ''}'),
                    isThreeLine: c.direccion != null,
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