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

class MyApp extends StatelessWidget {
  final Repositorio repo;
  const MyApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Pistón',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE65100), // Naranja industrial
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins', // Si no tienes la fuente, quita esta línea
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: MainScreen(repo: repo),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Repositorio repo;
  const MainScreen({super.key, required this.repo});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      OrdenesScreen(repo: widget.repo),
      ClientesScreen(repo: widget.repo),
      RepuestosScreen(repo: widget.repo),
    ];

    return Scaffold(
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