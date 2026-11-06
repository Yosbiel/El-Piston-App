import 'package:flutter/material.dart';
import 'data/database.dart';
import 'data/repositorio.dart';
import 'views/clientes_screen.dart';
import 'views/ordenes_screen.dart';
import 'views/repuestos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase(AppDatabase.openConnection());
  await db.crearTablas();
  final repo = Repositorio(db);
  runApp(MyApp(repo: repo));
}

class MyApp extends StatefulWidget {
  final Repositorio repo;
  const MyApp({super.key, required this.repo});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _cambiarTema() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Pistón',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE65100), // Naranja industrial
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE65100),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: MainScreen(repo: widget.repo, onCambiarTema: _cambiarTema),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Repositorio repo;
  final VoidCallback onCambiarTema;
  const MainScreen({super.key, required this.repo, required this.onCambiarTema});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _titulos = ['Órdenes de Servicio', 'Clientes', 'Inventario de Repuestos'];

  @override
  Widget build(BuildContext context) {
    final screens = [
      OrdenesScreen(repo: widget.repo),
      ClientesScreen(repo: widget.repo),
      RepuestosScreen(repo: widget.repo),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_index]),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark 
                ? Icons.light_mode 
                : Icons.dark_mode),
            onPressed: widget.onCambiarTema,
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.build_circle_outlined), selectedIcon: Icon(Icons.build_circle), label: 'Órdenes'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clientes'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Repuestos'),
        ],
      ),
    );
  }
}