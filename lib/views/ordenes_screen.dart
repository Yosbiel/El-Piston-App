import 'package:flutter/material.dart';
import '../data/repositorio.dart';
import '../models/orden.dart';

class OrdenesScreen extends StatefulWidget {
  final Repositorio repo;
  const OrdenesScreen({super.key, required this.repo});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  List<Orden> _ordenes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() async {
    final data = await widget.repo.obtenerOrdenes();
    if (mounted) setState(() => _ordenes = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes')),
      body: ListView.builder(
        itemCount: _ordenes.length,
        itemBuilder: (_, i) => ListTile(
          title: Text('Orden #${_ordenes[i].id}'),
          subtitle: Text(_ordenes[i].estado),
        ),
      ),
    );
  }
}