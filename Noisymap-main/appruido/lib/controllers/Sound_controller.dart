import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'login_controller.dart'; // Importar controlador de login.

class SoundController {
  final NoiseMeter _noiseMeter = NoiseMeter();
  late StreamSubscription<NoiseReading> _noiseSubscription;
  bool _isRecording = false;
  late NoiseReading _noiseReading;

  final String apiUrl = 'http://192.168.1.9/apis/Api_GuardarSonido.php'; // Cambia esta URL según la direccion ipv4

  // Verificar permisos de micrófono
  Future<void> requestMicrophonePermission() async {
    print("Solicitando permisos de micrófono...");
    if (!await Permission.microphone.isGranted) {
      await Permission.microphone.request();
    }
    print("Permiso de micrófono concedido: ${await Permission.microphone.isGranted}");
  }

  // Verificar permisos de ubicación
  Future<void> requestLocationPermission() async {
    print("Solicitando permisos de ubicación...");
    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }
    print("Permiso de ubicación concedido: ${await Permission.location.isGranted}");
  }

  // Iniciar medición de ruido
  Future<void> startRecording(Function(NoiseReading) onNoiseUpdated) async {
    try {
      await requestMicrophonePermission();

      // Subscribe to the noise level
      _noiseSubscription = _noiseMeter.noise.listen((NoiseReading noiseReading) {
        if (noiseReading != null) {
          // Debugging: Check the noise reading value
          print("Noise level: ${noiseReading.meanDecibel} dB");

          // Update state with valid noise reading
          onNoiseUpdated(noiseReading);
          _noiseReading = noiseReading;
        } else {
          print("Noise reading is null!");
        }
      });
      _isRecording = true;
    } catch (e) {
      print("Error al iniciar medición de ruido: $e");
    }
  }

  // Detener medición de ruido
  void stopRecording() {
    print("Deteniendo medición de ruido...");
    _noiseSubscription.cancel();
    _isRecording = false;
  }

  // Validar datos antes de enviar
  bool _validateData(double noiseLevel, Position position, int? userId) {
    print("Validando datos...");
    print("Usuario ID: $userId");
    print("Nivel de ruido: $noiseLevel");
    print("Latitud: ${position.latitude}, Longitud: ${position.longitude}");

    if (userId == null) {
      print("Error: Usuario no logueado.");
      return false;
    }
    if (noiseLevel < 0 || noiseLevel > 150) {
      print("Error: Nivel de ruido fuera de rango (0-150 dB).");
      return false;
    }
    if (position.latitude < -90 || position.latitude > 90 || position.longitude < -180 || position.longitude > 180) {
      print("Error: Coordenadas inválidas.");
      return false;
    }
    return true;
  }

  // Guardar nivel de ruido en la API
  Future<void> saveNoiseLevel(BuildContext context) async {
    if (_isRecording) stopRecording();

    print("Obteniendo posición GPS...");
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double noiseLevel = _noiseReading.meanDecibel;

    int? userId = LoginController.userId; // Obtener el ID del usuario logueado.

    // Validar los datos
    if (!_validateData(noiseLevel, position, userId)) {
      _showDialog(context, "Error", "Datos inválidos. Por favor verifica los valores ingresados.");
      return;
    }

    print("Enviando datos a la API...");
    print("URL de la API: $apiUrl");
    print("Datos enviados: { userID: $userId, noiseLevel: $noiseLevel, latitude: ${position.latitude}, longitude: ${position.longitude} }");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': userId,
          'noiseLevel': noiseLevel,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      print("Código de respuesta del servidor: ${response.statusCode}");
      print("Respuesta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 1) {
            _showDialog(context, "Éxito", "El nivel promedio de ruido guardado exitosamente.");
          } else {
            print("Error en la API: ${responseData['message']}");
            _showDialog(context, "Error", responseData['message']);
          }
        } catch (e) {
          print("Error al procesar la respuesta JSON: $e");
          _showDialog(context, "Error", "Error al procesar la respuesta del servidor.");
        }
      } else {
        print("Error HTTP: ${response.statusCode}");
        _showDialog(context, "Error", "Error en la conexión con el servidor.");
      }
    } catch (e) {
      print("Excepción al guardar datos: $e");
      String errorMessage = 'Ocurrió un error inesperado';

      if (e is SocketException) {
        errorMessage = 'No se pudo conectar al servidor. Verifica tu conexión.';
      } else if (e is TimeoutException) {
        errorMessage = 'La solicitud ha tardado demasiado en procesarse.';
      }

      _showDialog(context, "Error", errorMessage);
    }
  }

  // Mostrar diálogos
  void _showDialog(BuildContext context, String title, String message) {
    print("$title: $message");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          )
        ],
      ),
    );
  }
}