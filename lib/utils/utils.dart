import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.white,
      textColor: Colors.blueAccent,
      fontSize: 18.0,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  static void flushBarErrorMessage(String message, BuildContext context) {
    Flushbar(
      forwardAnimationCurve: Curves.decelerate,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      message: message,
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(16),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red,
      reverseAnimationCurve: Curves.easeInOut,
      positionOffset: 20,
      icon: const Icon(Icons.error, size: 28, color: Colors.white),
    ).show(context);
  }

  static void flushBarSuccessMessage(String message, BuildContext context) {
    Flushbar(
      forwardAnimationCurve: Curves.decelerate,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      message: message,
      duration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(16),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.green,
      reverseAnimationCurve: Curves.easeInOut,
      positionOffset: 20,
      icon: const Icon(Icons.check_circle, size: 28, color: Colors.white),
    ).show(context);
  }
  static IconData getKindIcon(String? kind) {
    if (kind == null) return Icons.place_outlined;
    final k = kind.toLowerCase();

    if (k.contains('historic')) return Icons.history_edu;
    if (k.contains('religion')) return Icons.account_balance;
    if (k.contains('natural') || k.contains('garden')) return Icons.park_outlined;
    if (k.contains('bridge')) return Icons.landscape_outlined;
    if (k.contains('cemetery') || k.contains('burial')) return Icons.foundation;
    if (k.contains('architecture')) return Icons.architecture;
    if (k.contains('museum')) return Icons.museum_outlined;
    if (k.contains('industrial')) return Icons.business;

    return Icons.explore_outlined; // Default fallback
  }
}
