import 'package:flutter/material.dart';

/// Icono de menú con tres barras asimétricas.
class MenuIconAsimetrico extends StatelessWidget {
  final Color? color;
  final double size;
  const MenuIconAsimetrico({super.key, this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MenuPainter(color: c)),
    );
  }
}

class _MenuPainter extends CustomPainter {
  final Color color;
  _MenuPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    // Tres líneas con longitudes distintas
    canvas.drawLine(Offset(0, h * 0.25), Offset(w * 0.6, h * 0.25), paint);   // Arriba: corta
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), paint);           // Medio: larga
    canvas.drawLine(Offset(0, h * 0.75), Offset(w * 0.8, h * 0.75), paint);   // Abajo: mediana
  }

  @override
  bool shouldRepaint(covariant _MenuPainter oldDelegate) => oldDelegate.color != color;
}