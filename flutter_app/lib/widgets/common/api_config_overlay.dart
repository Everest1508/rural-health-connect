import 'package:flutter/material.dart';
import 'api_config_button.dart';

/// NavigatorObserver that adds API config button overlay to all routes
class ApiConfigOverlay extends NavigatorObserver {
  static OverlayEntry? _overlayEntry;
  static bool _isAdded = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final navigator = route.navigator;
    if (navigator != null) {
      addOverlay(navigator.context);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      final navigator = newRoute.navigator;
      if (navigator != null) {
        addOverlay(navigator.context);
      }
    }
  }

  static void addOverlay(BuildContext context) {
    // Only add once
    if (_isAdded) {
      print('ApiConfigOverlay: Already added, skipping');
      return;
    }
    
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      print('ApiConfigOverlay: No overlay found');
      return;
    }

    print('ApiConfigOverlay: Adding overlay entry');
    _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        bottom: 80,
        right: 16,
        child: IgnorePointer(
          ignoring: false,
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            child: const ApiConfigButton(),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _isAdded = true;
    print('ApiConfigOverlay: Overlay entry added successfully');
  }

  static void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isAdded = false;
  }
}

