import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/database.dart';
import 'data/repositorio.dart';
import 'views/clientes_screen.dart';
import 'views/ordenes_screen.dart';
import 'views/repuestos_screen.dart';
import 'views/vehiculos_screen.dart';
import 'views/mecanicos_screen.dart';
import 'views/reportes_screen.dart';
import 'widgets/menu_icon.dart'; // <-- NUEVO IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late Future<Repositorio> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _inicializarApp();
  }

  Future<Repositorio> _inicializarApp() async {
    final db = AppDatabase(AppDatabase.openConnection());
    await db.crearTablas();
    await db.migrar(); // <-- Migración para añadir el rol
    final repo = Repositorio(db);
    final tema = await repo.obtenerTema();
    if (tema != null && mounted) setState(() => _themeMode = tema == 'dark' ? ThemeMode.dark : ThemeMode.light);
    return repo;
  }

  void _cambiarTema() async {
    final nuevoModo = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setState(() => _themeMode = nuevoModo);
    final repo = await _initFuture;
    await repo.guardarTema(nuevoModo == ThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Pistón',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100), brightness: Brightness.light),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100), brightness: Brightness.dark),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      home: FutureBuilder<Repositorio>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const _PantallaCarga();
          if (snapshot.hasError) return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
          final repo = snapshot.data!;
          return MainScreen(
            repo: repo,
            themeMode: _themeMode,
            onCambiarTema: _cambiarTema,
          );
        },
      ),
    );
  }
}

class _PantallaCarga extends StatelessWidget {
  const _PantallaCarga();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          const Text('El Pistón', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Cargando taller...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );
}

class MainScreen extends StatefulWidget {
  final Repositorio repo;
  final ThemeMode themeMode;
  final VoidCallback onCambiarTema;

  const MainScreen({
    super.key,
    required this.repo,
    required this.themeMode,
    required this.onCambiarTema,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final PageController _pageController = PageController();
  final _titulos = ['Órdenes', 'Clientes', 'Vehículos', 'Repuestos', 'Mecánicos', 'Reportes'];

  void _navegarA(int index) {
    Navigator.pop(context);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _mostrarInformacion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.build, color: Colors.orange),
            SizedBox(width: 8),
            Text('El Pistón'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gestión de Taller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            Text(
              'Aplicación para la gestión de clientes, vehículos, órdenes de servicio y repuestos del taller El Pistón.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text('Desarrollado por:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Yosbiel Alejandro Díaz Cala'),
            SizedBox(height: 8),
            Text(
              'Asignatura: Programación para Dispositivos Móviles',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _confirmarSalida() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar la app?'),
        content: const Text('¿Estás seguro que deseas salir de El Pistón?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              SystemNavigator.pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      OrdenesScreen(repo: widget.repo),
      ClientesScreen(repo: widget.repo),
      VehiculosScreen(repo: widget.repo),
      RepuestosScreen(repo: widget.repo),
      MecanicosScreen(repo: widget.repo),
      ReportesScreen(repo: widget.repo),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_index]),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const MenuIconAsimetrico(), // <-- ICONO ASIMÉTRICO
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.build, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  const Text('El Pistón', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Gestión de Taller', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            _drawerItem(Icons.build, 'Órdenes', 0),
            _drawerItem(Icons.people, 'Clientes', 1),
            _drawerItem(Icons.directions_car, 'Vehículos', 2),
            _drawerItem(Icons.inventory_2, 'Repuestos', 3),
            _drawerItem(Icons.person, 'Mecánicos', 4),
            _drawerItem(Icons.bar_chart, 'Reportes', 5),
            const Divider(),
            ListTile(
              leading: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
              title: Text(widget.themeMode == ThemeMode.dark ? 'Modo Claro' : 'Modo Oscuro'),
              onTap: () {
                Navigator.pop(context);
                widget.onCambiarTema();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Información'),
              onTap: _mostrarInformacion,
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Cerrar App', style: TextStyle(color: Colors.red)),
              onTap: _confirmarSalida,
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _index = i),
        children: screens,
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final selected = _index == index;
    return ListTile(
      leading: Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      onTap: () => _navegarA(index),
    );
  }
}