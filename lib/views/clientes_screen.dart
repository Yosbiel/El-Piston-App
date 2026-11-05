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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: telefonoCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: direccionCtrl,
                decoration: const InputDecoration(labelText: 'Dirección (opcional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await widget.repo.insertarCliente(Cliente(
                  nombre: nombreCtrl.text,
                  telefono: telefonoCtrl.text,
                  direccion: direccionCtrl.text.isEmpty ? null : direccionCtrl.text,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                _cargar();
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
      appBar: AppBar(title: const Text('Clientes')),
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