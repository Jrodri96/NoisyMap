import 'package:flutter/material.dart';
import 'package:appruido/controllers/Sound_controller.dart';

class SoundView extends StatefulWidget {
  @override
  _SoundViewState createState() => _SoundViewState();
}

class _SoundViewState extends State<SoundView> {
  final SoundController _soundController = SoundController();
  double _currentDecibel = 0.0;
  bool _isMeasuring = false;

  void _startMeasurement() {
    setState(() {
      _isMeasuring = true;
    });
    _soundController.startRecording((noiseReading) {
      if (mounted) {
        setState(() {
          _currentDecibel = noiseReading.meanDecibel;
        });
      }
    });
  }

  void _stopMeasurement() {
    _soundController.stopRecording();
    if (mounted) {
      setState(() {
        _isMeasuring = false;
      });
    }
  }

  void _saveReport() {
    _soundController.saveNoiseLevel(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Medición de Ruido",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Visualización del nivel de ruido
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: _isMeasuring ? Colors.green.shade100 : Colors.grey.shade200,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${_currentDecibel.toStringAsFixed(2)} dB',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nivel de Ruido Promedio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54),
            ),
            SizedBox(height: 40),
            // Botones de acciones
            Column(
              children: [
                FilledButton.icon(
                  onPressed: _startMeasurement,
                  icon: Icon(Icons.play_arrow),
                  label: Text("Iniciar Medición"),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _stopMeasurement,
                  icon: Icon(Icons.stop),
                  label: Text("Detener Medición"),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saveReport,
                  icon: Icon(Icons.save),
                  label: Text("Guardar Reporte"),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    // Ensure we cancel the stream subscription in the dispose method
    _soundController.stopRecording();
    super.dispose();
  }
}

