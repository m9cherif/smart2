import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayService extends WindowListener with TrayListener {
  TrayService._();
  static final TrayService instance = TrayService._();

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    try {
      if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        return;
      }

      await windowManager.ensureInitialized();
      windowManager.addListener(this);
      await windowManager.setPreventClose(true);

      trayManager.addListener(this);
      await _initTray();
    } catch (e) {
      debugPrint('TrayService/WindowManager could not initialize: $e');
      // This often happens if the app needs a full rebuild after adding plugins.
    }
  }

  Future<void> _initTray() async {
    try {
      String iconPath = Platform.isWindows ? 'logo.ico' : 'logo.png';
      // In some environments, the path needs careful handling.
      await trayManager.setIcon(iconPath);
    } catch (_) {
      // If icon load fails, try alternate path or continue without icon
    }

    try {
      List<MenuItem> items = [
        MenuItem(
          key: 'show_window',
          label: 'Show App',
        ),
        MenuItem(
          key: 'hide_window',
          label: 'Hide App',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit',
        ),
      ];
      await trayManager.setContextMenu(Menu(items: items));
    } catch (_) {}
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      windowManager.show();
    } else if (menuItem.key == 'hide_window') {
      windowManager.hide();
    } else if (menuItem.key == 'exit_app') {
      windowManager.destroy(); // Entirely close
    }
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    }
  }
}
