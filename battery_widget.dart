import 'package:flutter/material.dart';

class BatteryWidget extends StatelessWidget {
  final int percent;
  const BatteryWidget({super.key, required this.percent});

  Color _batteryColor() {
    if (percent >= 80) return Colors.greenAccent;
    if (percent >= 40) return Colors.amber;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final level = (percent.clamp(0,100) / 100.0);
    return Column(
      children: [
        Text(
          '$percent%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: 220,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white70, width: 2),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutExpo,
              width: 220 * level,
              height: 48,
              decoration: BoxDecoration(
                color: _batteryColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _batteryColor().withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
