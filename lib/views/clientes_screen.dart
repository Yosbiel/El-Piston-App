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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: ListView.builder(
        itemCount: _clientes.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(_clientes[i].nombre),
          subtitle: Text(_clientes[i].telefono),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget.repo.insertarCliente(Cliente(nombre: 'Nuevo', telefono: '12345678'));
          _cargar();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}