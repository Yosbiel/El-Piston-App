import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/cliente.dart';
import '../widgets/animaciones.dart';
import '../utils/toast.dart';

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

  void _eliminar(Cliente c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar cliente?'),
        content: Text('Se eliminará a ${c.nombre} permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.repo.eliminarCliente(c.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _cargar();
              mostrarToast(context, 'Cliente eliminado');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFormulario() {
    final nombreCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? _errorTelefono;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: const Text('Nuevo Cliente'),
            content: Form(
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
                      validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: telefonoCtrl,
                      maxLength: 8,
                      decoration: InputDecoration(
                        labelText: 'Teléfono *',
                        border: const OutlineInputBorder(),
                        errorText: _errorTelefono,
                        counterStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'El teléfono es obligatorio';
                        if (v.length < 8) return 'Mínimo 8 dígitos';
                        if (int.tryParse(v) == null) return 'Debe ser numérico';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: direccionCtrl,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        labelText: 'Dirección (opcional)',
                        border: OutlineInputBorder(),
                        counterStyle: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
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
                    final telefono = telefonoCtrl.text.trim();
                    if (await widget.repo.existeTelefono(telefono)) {
                      setStateDialog(() => _errorTelefono = 'Ese teléfono ya está registrado');
                      return;
                    }
                    setStateDialog(() => _errorTelefono = null);
                    await widget.repo.insertarCliente(Cliente(
                      nombre: nombreCtrl.text.trim(),
                      telefono: telefono,
                      direccion: direccionCtrl.text.trim().isEmpty ? null : direccionCtrl.text.trim(),
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    _cargar();
                    mostrarToast(context, 'Cliente guardado con éxito');
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
      body: _clientes.isEmpty
          ? const AnimatedEmptyText(texto: 'No hay clientes registrados')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _clientes.length,
              itemBuilder: (_, i) {
                final c = _clientes[i];
                return AnimatedCard(
                  index: i,
                  child: Card(
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
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _eliminar(c),
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