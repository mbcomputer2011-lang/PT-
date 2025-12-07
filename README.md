Anti-Lost Keychain - Flutter demo project
=========================================

This package contains a minimal Flutter project skeleton with:
- UI (glass-style blue buttons)
- Battery animated widget
- BLE service scaffold using flutter_reactive_ble
- Background helper (flutter_background) setup notes

IMPORTANT:
- This is a starting template. You must run `flutter pub get` and open the project in Android Studio.
- On Android, enable required runtime permissions (LOCATION/BLE) and enable foreground service for reliable background behavior.
- Test and adapt the BLE UUIDs if needed.

Device/service UUIDs used in the sample (from your ESP32 code):
- Service: 4afc0001-5f4c-4f89-a5ab-1e7f91b45abc
- CMD Char: 4afc0002-5f4c-4f89-a5ab-1e7f91b45abc (write)
- BATT Char: 4afc0003-5f4c-4f89-a5ab-1e7f91b45abc (notify)

Build:
- flutter pub get
- flutter run -d <device>

If you want, I can expand this into a full Android Studio project (with Android manifest edits) or set up GitHub Actions to build APK automatically.
