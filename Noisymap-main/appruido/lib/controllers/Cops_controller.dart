import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CopsController {
  static Future<void> callEmergencyLine() async {
    final Uri emergencyNumber = Uri(scheme: 'tel', path: '123'); // Formato URI

    if (await canLaunchUrl(emergencyNumber)) {
      await launchUrl(emergencyNumber);
    } else {
      debugPrint('No se puede realizar la llamada al número de emergencia.');
    }
  }
}
