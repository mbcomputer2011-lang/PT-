import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ble/ble_service.dart';
import 'ui/battery_widget.dart';
import 'ui/buttons.dart';

void main() {
  runApp(const AntiLostApp());
}

class AntiLostApp extends StatelessWidget {
  const AntiLostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
      theme: ThemeData(fontFamily: 'Roboto'),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final BleService ble = BleService();
  int batteryPercent = 0;
  bool soundAlertEnabled = true;
  late StreamSubscription<int> rssiSub;
  late StreamSubscription<int> battSub;

  @override
  void initState() {
    super.initState();
    ble.initialize(); // prepare scanner
    // listen battery updates (from BLE notify)
    battSub = ble.batteryStream.listen((value) {
      setState(() {
        batteryPercent = value;
      });
    });
    // listen RSSI to detect distance; threshold around -72
    rssiSub = ble.rssiStream.listen((rssi) {
      if (soundAlertEnabled && rssi < -72) {
        _playWarning();
      }
    });
  }

  @override
  void dispose() {
    battSub.cancel();
    rssiSub.cancel();
    ble.dispose();
    super.dispose();
  }

  void _playWarning() async {
    final player = AudioPlayer();
    // short beep; in real app bundle an asset or use system sounds
    await player.play(UrlSource('https://actions.google.com/sounds/v1/alarms/beep_short.ogg'));
  }

  void _sendCmd(String cmd) {
    ble.writeCommand(cmd);
  }

  void _reqBatt() {
    // Request battery from device (writes REQ_BATT)
    _sendCmd('REQ_BATT');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Anti-Lost Key ESP32-C3",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              BatteryWidget(percent: batteryPercent),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // toggle alert
                    GlassButton(
                      text: soundAlertEnabled ? 'ปิดแจ้งเตือนเสียง' : 'เปิดแจ้งเตือนเสียง',
                      onTap: () => setState(() {
                        soundAlertEnabled = !soundAlertEnabled;
                      }),
                    ),
                    GlassButton(
                      text: 'BUZZER_ON',
                      onTap: () => _sendCmd('BUZZER_ON'),
                    ),
                    GlassButton(
                      text: 'BUZZER_OFF',
                      onTap: () => _sendCmd('BUZZER_OFF'),
                    ),
                    GlassButton(
                      text: 'LED_ON',
                      onTap: () => _sendCmd('LED_ON'),
                    ),
                    GlassButton(
                      text: 'LED_OFF',
                      onTap: () => _sendCmd('LED_OFF'),
                    ),
                    GlassButton(
                      text: 'REQ_BATT',
                      onTap: _reqBatt,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'RSSI: ${ble.lastRssi ?? '-'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ble.startScanAndConnect(),
                      child: const Text('Scan & Connect'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
