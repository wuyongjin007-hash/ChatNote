import 'package:flutter/foundation.dart';

class AppDrawerController {
  AppDrawerController._();

  static VoidCallback? _openDrawer;
  static Object? _owner;

  static void attach(Object owner, VoidCallback callback) {
    _owner = owner;
    _openDrawer = callback;
  }

  static void detach(Object owner) {
    if (identical(_owner, owner)) {
      _owner = null;
      _openDrawer = null;
    }
  }

  static void open() {
    _openDrawer?.call();
  }
}
