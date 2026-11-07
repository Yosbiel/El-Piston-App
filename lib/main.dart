import 'package:flutter/material.dart';
import 'data/database.dart';
import 'data/repositorio.dart';
import 'views/clientes_screen.dart';
import 'views/ordenes_screen.dart';
import 'views/repuestos_screen.dart';

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
    // Inicia la base de datos en segundo plano mientras se muestra la pantalla de carga.
    _initFuture = _inicializarApp();
  }

  /// Inicializa la base de datos y recupera el tema guardado.
  Future<Repositorio> _inicializarApp() async {
    final db = AppDatabase(AppDatabase.openConnection());
    await db.crearTablas();
    final repo = Repositorio(db);
    final tema = await repo.obtenerTema();
    if (tema != null && mounted) {
      setState(() {
        _themeMode = tema == 'dark' ? ThemeMode.dark : ThemeMode.light;
      });
    }
    return repo;
  }

  /// Cambia el tema y lo guarda en la base de datos para que se mantenga.
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
      // Mientras la base de datos se inicializa, se muestra la pantalla de carga.
      home: FutureBuilder<Repositorio>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _PantallaCarga();
          }
          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
          }
          final repo = snapshot.data!;
          return MainScreen(repo: repo, onCambiarTema: _cambiarTema);
        },
      ),
    );
  }
}

/// Pantalla que se muestra mientras la base de datos se inicializa.
class _PantallaCarga extends StatelessWidget {
  const _PantallaCarga();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  final PageController _pageController = PageController();
  final _titulos = ['Órdenes de Servicio', 'Clientes', 'Inventario de Repuestos'];

  /// Muestra un diálogo con la información del autor y del proyecto.
  void _mostrarInformacion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.build, color: Colors.orange),
            SizedBox(width: 8),
            Text('El Pistón'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Gestión de Taller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            Text('Aplicación para la gestión de clientes, vehículos, órdenes de servicio y repuestos del taller El Pistón.', textAlign: TextAlign.center),
            SizedBox(height: 16),
            Text('Desarrollado por:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Yosbiel Alejandro Díaz Cala'),
            SizedBox(height: 8),
            Text('Asignatura: Programación para Dispositivos Móviles', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

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
            icon: const Icon(Icons.info_outline),
            onPressed: _mostrarInformacion,
            tooltip: 'Información',
          ),
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onCambiarTema,
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      // PageView permite cambiar de pestaña con una animación de deslizamiento suave.
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _index = i),
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        items: [
          _buildItem(context, icon: Icons.build_circle_outlined, selectedIcon: Icons.build_circle, label: 'Órdenes', index: 0),
          _buildItem(context, icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Clientes', index: 1),
          _buildItem(context, icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: 'Repuestos', index: 2),
        ],
      ),
    );
  }

  /// Construye cada ítem de la barra inferior con el efecto de "píldora" en el activo.
  BottomNavigationBarItem _buildItem(BuildContext context, {required IconData icon, required IconData selectedIcon, required String label, required int index}) {
    final isSelected = _index == index;
    final colorScheme = Theme.of(context).colorScheme;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isSelected ? BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)) : null,
        child: Icon(icon, color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
        child: Icon(selectedIcon, color: colorScheme.onPrimaryContainer),
      ),
      label: label,
    );
  }
}