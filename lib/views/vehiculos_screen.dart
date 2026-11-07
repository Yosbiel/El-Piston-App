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
  String _busqueda = '';

  final List<String> _marcasPredefinidas = [
    'Toyota', 'Hyundai', 'Kia', 'Nissan', 'Chevrolet', 'Ford', 'Volkswagen', 'Honda', 'Mazda', 'Peugeot', 'Renault', 'Fiat'
  ];

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

  List<Vehiculo> get _filtrados {
    if (_busqueda.isEmpty) return _vehiculos;
    final q = _busqueda.toLowerCase();
    return _vehiculos.where((v) =>
      v.matricula.toLowerCase().contains(q) ||
      v.marca.toLowerCase().contains(q) ||
      v.modelo.toLowerCase().contains(q)
    ).toList();
  }

  void _eliminar(Vehiculo v) async {
    final tieneOrdenes = await widget.repo.vehiculoTieneOrdenesActivas(v.id!);
    if (tieneOrdenes) {
      if (mounted) mostrarToast(context, 'No se puede eliminar: tiene órdenes activas', esError: true);
      return;
    }
    if (!mounted) return;
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

  void _mostrarFormulario({Vehiculo? vehiculo}) async {
    if (vehiculo != null) {
      final tieneOrdenes = await widget.repo.vehiculoTieneOrdenesActivas(vehiculo.id!);
      if (tieneOrdenes) {
        if (mounted) mostrarToast(context, 'No se puede editar: tiene órdenes activas', esError: true);
        return;
      }
    }
    if (_clientes.isEmpty) {
      mostrarToast(context, 'Primero registra un cliente', esError: true);
      return;
    }

    final matriculaCtrl = TextEditingController(text: vehiculo?.matricula ?? '');
    final modeloCtrl = TextEditingController(text: vehiculo?.modelo ?? '');
    final anioCtrl = TextEditingController(text: vehiculo?.anio?.toString() ?? '');
    final kmCtrl = TextEditingController(text: vehiculo?.kilometraje?.toString() ?? '');
    int? clienteSeleccionado = vehiculo?.clienteId ?? _clientes.first.id;

    String marcaSeleccionada = vehiculo?.marca ?? _marcasPredefinidas.first;
    bool agregandoNuevaMarca = false;
    final nuevaMarcaCtrl = TextEditingController();

    final formKey = GlobalKey<FormState>();
    String? _errorMatricula;
    final anioActual = DateTime.now().year;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: Text(vehiculo == null ? 'Nuevo Vehículo' : 'Editar Vehículo'),
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
                        decoration: InputDecoration(labelText: 'Matrícula *', border: const OutlineInputBorder(), errorText: _errorMatricula, counterStyle: const TextStyle(fontSize: 10, color: Colors.grey)),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 8),
                      if (!agregandoNuevaMarca)
                        DropdownButtonFormField<String>(
                          value: marcaSeleccionada,
                          decoration: const InputDecoration(labelText: 'Marca *', border: OutlineInputBorder()),
                          items: [
                            ..._marcasPredefinidas.map((m) => DropdownMenuItem(value: m, child: Text(m))),
                            const DropdownMenuItem(value: '__nueva__', child: Text('Otra marca...')),
                          ],
                          onChanged: (v) {
                            if (v == '__nueva__') {
                              setStateDialog(() => agregandoNuevaMarca = true);
                            } else if (v != null) {
                              setStateDialog(() => marcaSeleccionada = v);
                            }
                          },
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: nuevaMarcaCtrl,
                                maxLength: 30,
                                decoration: const InputDecoration(labelText: 'Nueva marca *', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => setStateDialog(() => agregandoNuevaMarca = false),
                            ),
                          ],
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
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final anio = int.tryParse(v);
                          if (anio == null) return 'Debe ser un número';
                          if (anio < 1900) return 'Año inválido (mín. 1900)';
                          if (anio > anioActual) return 'No puede ser mayor a $anioActual';
                          return null;
                        },
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
                    if (await widget.repo.existeMatricula(mat, excluirId: vehiculo?.id)) {
                      setStateDialog(() => _errorMatricula = 'Esa matrícula ya existe');
                      return;
                    }
                    final marcaFinal = agregandoNuevaMarca ? nuevaMarcaCtrl.text.trim() : marcaSeleccionada;
                    if (vehiculo == null) {
                      await widget.repo.insertarVehiculo(Vehiculo(
                        clienteId: clienteSeleccionado!,
                        matricula: mat,
                        marca: marcaFinal,
                        modelo: modeloCtrl.text.trim(),
                        anio: int.tryParse(anioCtrl.text),
                        kilometraje: int.tryParse(kmCtrl.text),
                      ));
                    } else {
                      await widget.repo.actualizarVehiculo(Vehiculo(
                        id: vehiculo.id,
                        clienteId: clienteSeleccionado!,
                        matricula: mat,
                        marca: marcaFinal,
                        modelo: modeloCtrl.text.trim(),
                        anio: int.tryParse(anioCtrl.text),
                        kilometraje: int.tryParse(kmCtrl.text),
                      ));
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    _cargar();
                    mostrarToast(context, vehiculo == null ? 'Vehículo guardado' : 'Vehículo actualizado');
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
    final filtrados = _filtrados;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por matrícula, marca o modelo...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
          ),
          Expanded(
            child: filtrados.isEmpty
                ? const AnimatedEmptyText(texto: 'No hay vehículos registrados')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtrados.length,
                    itemBuilder: (_, i) {
                      final v = filtrados[i];
                      return AnimatedCard(
                        index: i,
                        child: Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.directions_car)),
                            title: Text('${v.marca} ${v.modelo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Matrícula: ${v.matricula}\nCliente: ${_nombreCliente(v.clienteId)}${v.anio != null ? ' | Año: ${v.anio}' : ''}'),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarFormulario(vehiculo: v)),
                                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _eliminar(v)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFab(onPressed: () => _mostrarFormulario()),
    );
  }
}