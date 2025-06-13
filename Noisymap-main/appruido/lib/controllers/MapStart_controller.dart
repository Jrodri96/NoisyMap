import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapStartController extends StatefulWidget {
  final Function()? onReloadMarkers;

  MapStartController({this.onReloadMarkers});

  @override
  _MapStartControllerState createState() => _MapStartControllerState();
}

class _MapStartControllerState extends State<MapStartController> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(0.0, 0.0);
  List<Marker> _markers = [];
  final String apiUrl = 'http://192.168.1.9/apis/Api_Registrosruido.php'; // Cambia esta URL según la direccion ipv4
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchNoiseRecords();
    // Iniciar el Timer para actualizar los marcadores cada 10 segundos
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchNoiseRecords();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Obtiene la ubicación actual del usuario
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Servicios de ubicación desactivados.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Permiso de ubicación denegado.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Permiso de ubicación denegado permanentemente.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      print("Coordenadas actuales: Latitud: ${position.latitude}, Longitud: ${position.longitude}");

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_currentPosition, 15.0);
    } catch (e) {
      print("Error obteniendo la ubicación: $e");
    }
  }

  /// Solicita los registros de ruido desde la API y actualiza los marcadores
  Future<void> _fetchNoiseRecords() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Respuesta de la API: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['status'] == 1) {
          _updateMarkers(data['data']);
        } else {
          print("Error en datos de la API: ${data['message']}");
        }
      } else {
        print("Error en la respuesta HTTP: Código ${response.statusCode}");
      }
    } catch (e) {
      print("Error en solicitud HTTP: $e");
    }
  }

  /// Actualiza los marcadores en el mapa con los datos obtenidos
  void _updateMarkers(List<dynamic> records) {
    List<Marker> markers = [];
    for (var record in records) {
      double nivelRuido = (record['Nivel_Ruido'] as num).toDouble();
      LatLng position = LatLng(
        (record['Latitud'] as num).toDouble(),
        (record['Longitud'] as num).toDouble(),
      );

      Color markerColor;
      if (nivelRuido < 65) {
        markerColor = Colors.green;
      } else if (nivelRuido < 85) {
        markerColor = Colors.yellow;
      } else {
        markerColor = Colors.red;
      }

      markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: position,
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Texto con el nivel de ruido
            Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: Text(
                "${nivelRuido.toStringAsFixed(1)} dB",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 4.0),
            Icon(Icons.location_pin, color: markerColor, size: 40),
          ],
        ),
      ));
    }

    setState(() {
      _markers = markers;
    });
  }

  /// Recarga los marcadores manualmente
  Future<void> reloadMarkers() async {
    await _fetchNoiseRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mapa ocupando el 70% de la pantalla superior
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,//Poner en 0.92 en caso tal de querer mostrar las web view
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition,
                zoom: 13.0,
                onMapReady: () {
                  if (_currentPosition.latitude != 0.0 && _currentPosition.longitude != 0.0) {
                    _mapController.move(_currentPosition, 15.0);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.appruido',
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
        ),
        // Botón para centrar en la ubicación actual
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.3 - 60, // Ajuste para la parte inferior derecha del 70%
          right: 16,
          child: FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: Icon(Icons.my_location),
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}
