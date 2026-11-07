import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/vehiculo.dart';
import '../models/cliente.dart';
import '../widgets/animaciones.dart';
import '../utils/toast.dart';

class VehiculosScreen extends StatefulWidget {
  final Repositorio repo;
  const VehiculosScreen({super.key, required this.repo});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  List<Vehiculo> _vehiculos = [];
  List<Cliente> _clientes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final v = await widget.repo.obtenerVehiculos();
    final c = await widget.repo.obtenerClientes();
    if (mounted) setState(() { _vehiculos = v; _clientes = c; });
  }

  String _nombreCliente(int id) {
    try { return _clientes.firstWhere((c) => c.id == id).nombre; } catch (_) { return 'Desconocido'; }
  }

  void _eliminar(Vehiculo v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar vehículo?'),
        content: Text('Se eliminará el vehículo con matrícula ${v.matricula}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.repo.eliminarVehiculo(v.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _cargar();
              mostrarToast(context, 'Vehículo eliminado');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFormulario() {
    if (_clientes.isEmpty) {
      mostrarToast(context, 'Primero registra un cliente', esError: true);
      return;
    }

    final matriculaCtrl = TextEditingController();
    final marcaCtrl = TextEditingController();
    final modeloCtrl = TextEditingController();
    final anioCtrl = TextEditingController();
    final kmCtrl = TextEditingController();
    int? clienteSeleccionado = _clientes.first.id;
    final formKey = GlobalKey<FormState>();
    String? _errorMatricula;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: const Text('Nuevo Vehículo'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: clienteSeleccionado,
                        decoration: const InputDecoration(labelText: 'Cliente *', border: OutlineInputBorder()),
                        items: _clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
                        onChanged: (v) => setStateDialog(() => clienteSeleccionado = v),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: matriculaCtrl,
                        maxLength: 15,
                        decoration: InputDecoration(
                          labelText: 'Matrícula *',
                          border: const OutlineInputBorder(),
                          errorText: _errorMatricula,
                          counterStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: marcaCtrl,
                        maxLength: 30,
                        decoration: const InputDecoration(labelText: 'Marca *', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: modeloCtrl,
                        maxLength: 30,
                        decoration: const InputDecoration(labelText: 'Modelo *', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: anioCtrl,
                        maxLength: 4,
                        decoration: const InputDecoration(labelText: 'Año', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: kmCtrl,
                        maxLength: 8,
                        decoration: const InputDecoration(labelText: 'Kilometraje', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                        keyboardType: TextInputType.number,
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
                    final mat = matriculaCtrl.text.trim();
                    if (await widget.repo.existeMatricula(mat)) {
                      setStateDialog(() => _errorMatricula = 'Esa matrícula ya existe');
                      return;
                    }
                    setStateDialog(() => _errorMatricula = null);
                    await widget.repo.insertarVehiculo(Vehiculo(
                      clienteId: clienteSeleccionado!,
                      matricula: mat,
                      marca: marcaCtrl.text.trim(),
                      modelo: modeloCtrl.text.trim(),
                      anio: int.tryParse(anioCtrl.text),
                      kilometraje: int.tryParse(kmCtrl.text),
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    _cargar();
                    mostrarToast(context, 'Vehículo guardado');
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
      body: _vehiculos.isEmpty
          ? const AnimatedEmptyText(texto: 'No hay vehículos registrados')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _vehiculos.length,
              itemBuilder: (_, i) {
                final v = _vehiculos[i];
                return AnimatedCard(
                  index: i,
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.directions_car)),
                      title: Text('${v.marca} ${v.modelo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Matrícula: ${v.matricula}\nCliente: ${_nombreCliente(v.clienteId)}'),
                      isThreeLine: true,
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _eliminar(v)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: AnimatedFab(onPressed: _mostrarFormulario),
    );
  }
}