import 'package:flutter/material.dart';

void mostrarToast(BuildContext context, String mensaje, {bool esError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(esError ? Icons.error : Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: esError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ),
  );
}