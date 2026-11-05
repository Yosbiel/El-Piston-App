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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repuestos')),
      body: ListView.builder(
        itemCount: _repuestos.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(_repuestos[i].nombre),
          subtitle: Text('Stock: ${_repuestos[i].stock}'),
        ),
      ),
    );
  }
}