import 'package:appruido/controllers/Heatstats_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class HeatMapView extends StatefulWidget {
  @override
  _HeatMapViewState createState() => _HeatMapViewState();
}

class _HeatMapViewState extends State<HeatMapView> {
  final HeatMapController _heatMapController = HeatMapController();
  final MapController _mapController = MapController();

  List<CircleMarker> _heatMapCircles = [];
  DateTime _selectedDate = DateTime.now();
  int? _selectedHour; // Permite valores nulos para "Sin hora"
  bool _isLoading = false;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _fetchHeatMapData();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation!, 13.0);
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
      setState(() {
        _currentLocation = LatLng(0, 0);
      });
    }
  }

  Future<void> _fetchHeatMapData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      // Enviar `null` como rango específico si es "Sin hora"
      final data = await _heatMapController.fetchClusteredHeatMapData(
        formattedDate,
        hora: _selectedHour, // Pasar el valor nulo o la hora seleccionada
      );

      setState(() {
        _heatMapCircles = data.map((entry) {
          final double intensity = entry['nivelRuido'];
          final LatLng position = LatLng(entry['lat'], entry['lng']);

          Color color;
          if (intensity < 65) {
            color = Colors.green.withOpacity(0.5);
          } else if (intensity < 85) {
            color = Colors.yellow.withOpacity(0.5);
          } else {
            color = Colors.red.withOpacity(0.5);
          }

          return CircleMarker(
            point: position,
            radius: 50,
            color: color,
            borderColor: Colors.transparent,
          );
        }).toList();
      });
    } catch (e) {
      print('Error al cargar los datos del mapa de calor: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedHour = null; // Restablecer hora para mostrar todo el día
      });
      _fetchHeatMapData();
    }
  }

  void _goToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa de Calor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation ?? LatLng(0, 0),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.appruido',
              ),
              CircleLayer(circles: _heatMapCircles),
            ],
          ),
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Card(
              elevation: 10,
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 16.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.calendar_today),
                      label: Text('Fecha'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                      ),
                    ),
                    DropdownButton<int?>(
                      hint: Text('Hora'),
                      value: _selectedHour,
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Sin hora'),
                        ),
                        ...List.generate(24, (index) => index).map((hour) {
                          return DropdownMenuItem<int?>(
                            value: hour,
                            child: Text(hour == 0 ? '00:00 (medianoche)' : '$hour:00'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedHour = value; // `null` ahora es explícito
                        });
                        _fetchHeatMapData();
                      },
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                      underline: Container(
                        height: 1,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
