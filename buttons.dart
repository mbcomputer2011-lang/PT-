import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const GlassButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.24),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
                color: Colors.blueAccent.withOpacity(0.24),
                blurRadius: 12,
                spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
