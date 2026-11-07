import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/mecanico.dart';
import '../widgets/animaciones.dart';
import '../utils/toast.dart';

class MecanicosScreen extends StatefulWidget {
  final Repositorio repo;
  const MecanicosScreen({super.key, required this.repo});

  @override
  State<MecanicosScreen> createState() => _MecanicosScreenState();
}

class _MecanicosScreenState extends State<MecanicosScreen> {
  List<Mecanico> _mecanicos = [];

  // Roles predefinidos
  final List<String> _rolesPredefinidos = [
    'General', 'Motor', 'Frenos', 'Suspensión', 'Electricidad', 'Transmisión', 'Aire Acondicionado'
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final d = await widget.repo.obtenerMecanicos();
    if (mounted) setState(() => _mecanicos = d);
  }

  void _eliminar(Mecanico m) async {
    final tieneOrdenes = await widget.repo.mecanicoTieneOrdenesActivas(m.id!);
    if (tieneOrdenes) {
      if (mounted) mostrarToast(context, 'No se puede eliminar: tiene órdenes activas', esError: true);
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar mecánico?'),
        content: Text('Se eliminará a ${m.nombre}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.repo.eliminarMecanico(m.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _cargar();
              mostrarToast(context, 'Mecánico eliminado');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFormulario({Mecanico? mecanico}) async {
    if (mecanico != null) {
      final tieneOrdenes = await widget.repo.mecanicoTieneOrdenesActivas(mecanico.id!);
      if (tieneOrdenes) {
        if (mounted) mostrarToast(context, 'No se puede editar: tiene órdenes activas', esError: true);
        return;
      }
    }

    final nombreCtrl = TextEditingController(text: mecanico?.nombre ?? '');
    String rolSeleccionado = mecanico?.rol ?? 'General';
    bool agregandoNuevoRol = false;
    final nuevoRolCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? _errorNombre;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: Text(mecanico == null ? 'Nuevo Mecánico' : 'Editar Mecánico'),
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
                        decoration: InputDecoration(
                          labelText: 'Nombre *',
                          border: const OutlineInputBorder(),
                          errorText: _errorNombre,
                          counterStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 8),
                      if (!agregandoNuevoRol)
                        DropdownButtonFormField<String>(
                          value: rolSeleccionado,
                          decoration: const InputDecoration(labelText: 'Rol / Especialidad', border: OutlineInputBorder()),
                          items: [
                            ..._rolesPredefinidos.map((r) => DropdownMenuItem(value: r, child: Text(r))),
                            const DropdownMenuItem(value: '__nuevo__', child: Text('Añadir nueva función...')),
                          ],
                          onChanged: (v) {
                            if (v == '__nuevo__') {
                              setStateDialog(() => agregandoNuevoRol = true);
                            } else if (v != null) {
                              setStateDialog(() => rolSeleccionado = v);
                            }
                          },
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: nuevoRolCtrl,
                                maxLength: 30,
                                decoration: const InputDecoration(labelText: 'Nueva función *', border: OutlineInputBorder(), counterStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => setStateDialog(() => agregandoNuevoRol = false),
                            ),
                          ],
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
                    final nom = nombreCtrl.text.trim();
                    if (await widget.repo.existeMecanico(nom, excluirId: mecanico?.id)) {
                      setStateDialog(() => _errorNombre = 'Ese mecánico ya existe');
                      return;
                    }
                    final rolFinal = agregandoNuevoRol ? nuevoRolCtrl.text.trim() : rolSeleccionado;
                    if (mecanico == null) {
                      await widget.repo.insertarMecanico(Mecanico(nombre: nom, rol: rolFinal));
                    } else {
                      await widget.repo.actualizarMecanico(Mecanico(id: mecanico.id, nombre: nom, rol: rolFinal));
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    _cargar();
                    mostrarToast(context, mecanico == null ? 'Mecánico guardado' : 'Mecánico actualizado');
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
      body: _mecanicos.isEmpty
          ? const AnimatedEmptyText(texto: 'No hay mecánicos registrados')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _mecanicos.length,
              itemBuilder: (_, i) {
                final m = _mecanicos[i];
                return AnimatedCard(
                  index: i,
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Rol: ${m.rol}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarFormulario(mecanico: m)),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _eliminar(m)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: AnimatedFab(onPressed: () => _mostrarFormulario()),
    );
  }
}