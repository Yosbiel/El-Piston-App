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

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final d = await widget.repo.obtenerMecanicos();
    if (mounted) setState(() => _mecanicos = d);
  }

  void _eliminar(Mecanico m) {
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

  void _mostrarFormulario() {
    final nombreCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? _errorNombre;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: const Text('Nuevo Mecánico'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Form(
                key: formKey,
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
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final nom = nombreCtrl.text.trim();
                    if (await widget.repo.existeMecanico(nom)) {
                      setStateDialog(() => _errorNombre = 'Ese mecánico ya existe');
                      return;
                    }
                    setStateDialog(() => _errorNombre = null);
                    await widget.repo.insertarMecanico(Mecanico(nombre: nom));
                    if (ctx.mounted) Navigator.pop(ctx);
                    _cargar();
                    mostrarToast(context, 'Mecánico guardado');
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
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _eliminar(m)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: AnimatedFab(onPressed: _mostrarFormulario),
    );
  }
}