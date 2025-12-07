import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// UUIDs from ESP32 sketch
final Uuid serviceUuid = Uuid.parse('4afc0001-5f4c-4f89-a5ab-1e7f91b45abc');
final Uuid cmdCharUuid = Uuid.parse('4afc0002-5f4c-4f89-a5ab-1e7f91b45abc');
final Uuid battCharUuid = Uuid.parse('4afc0003-5f4c-4f89-a5ab-1e7f91b45abc');

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription? _scanSub;
  StreamSubscription? _connSub;
  QualifiedCharacteristic? _cmdChar;
  QualifiedCharacteristic? _battChar;
  String? connectedDeviceId;
  int? lastRssi;

  final StreamController<int> _rssiController = StreamController.broadcast();
  final StreamController<int> _battController = StreamController.broadcast();

  Stream<int> get rssiStream => _rssiController.stream;
  Stream<int> get batteryStream => _battController.stream;

  void initialize() {
    // nothing to do for now
  }

  void dispose() {
    _scanSub?.cancel();
    _connSub?.cancel();
    _rssiController.close();
    _battController.close();
  }

  void startScanAndConnect() {
    // scan for device name "AntiLost-Keychain"
    _scanSub = _ble.scanForDevices(withServices: []).listen((device) {
      // device.name may be empty depending on advertising
      if (device.name != null && device.name.contains('AntiLost-Keychain')) {
        // got it — stop scan and connect
        _scanSub?.cancel();
        _connect(device.id);
      }
    }, onError: (err) {
      // handle error
    });
  }

  void _connect(String deviceId) {
    _connSub = _ble.connectToDevice(id: deviceId).listen((connectionState) async {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        connectedDeviceId = deviceId;
        // discover characteristics by reading services
        final services = await _ble.discoverServices(deviceId);
        // Find characteristics by UUIDs
        for (final s in services) {
          for (final c in s.characteristics) {
            if (c.characteristicId == cmdCharUuid.toString()) {
              _cmdChar = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: cmdCharUuid, deviceId: deviceId);
            }
            if (c.characteristicId == battCharUuid.toString()) {
              _battChar = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: battCharUuid, deviceId: deviceId);
              // subscribe to notifications
              _ble.subscribeToCharacteristic(_battChar!).listen((data) {
                if (data.isNotEmpty) {
                  // ESP32 sends single byte percent
                  final percent = data[0];
                  _battController.add(percent);
                }
              });
            }
          }
        }
      } else {
        // disconnected
        connectedDeviceId = null;
      }
    }, onError: (e) {
      // handle connection error
    });
  }

  // Write simple UTF8 string command to write characteristic
  Future<void> writeCommand(String cmd) async {
    if (_cmdChar == null) return;
    final bytes = utf8.encode(cmd);
    try {
      await _ble.writeCharacteristicWithResponse(_cmdChar!, value: bytes);
    } catch (e) {
      // fallback: write without response
      try {
        await _ble.writeCharacteristicWithoutResponse(_cmdChar!, value: bytes);
      } catch (_) {}
    }
  }

  // Request battery by writing REQ_BATT
  Future<void> requestBattery() async {
    await writeCommand('REQ_BATT');
  }

  // Lightweight RSSI monitoring by scanning periodically for the same device id
  // Note: flutter_reactive_ble does not provide readRssi directly; we approximate by scanning results.
  Future<void> pollRssiPeriodically() async {
    // simple loop that scans briefly and extracts RSSI for the connected device
    Timer.periodic(Duration(seconds: 2), (t) {
      _ble.scanForDevices(withServices: []).listen((device) {
        if (device.id == connectedDeviceId) {
          lastRssi = device.rssi;
          _rssiController.add(device.rssi);
        }
      }).onDone((){});
    });
  }
}
