import 'package:appruido/controllers/Webreports_controller.dart';
import 'package:flutter/material.dart';
import 'package:appruido/controllers/MapStart_Controller.dart';
import 'dart:async';

class WebView extends StatefulWidget {
  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final WebReportsController webReportsController = WebReportsController();
  bool isLoadingReports = true;
  String errorMessage = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchReports();
    });
  }

  Future<void> _fetchReports() async {
    setState(() {
      isLoadingReports = true;
      errorMessage = '';
    });

    await webReportsController.fetchReports();

    setState(() {
      isLoadingReports = false;
      if (webReportsController.reportData.isEmpty) {
        errorMessage = 'No se han recibido reportes.';
      } else {
        errorMessage = '';
      }
    });
  }

  Color getNoiseLevelColor(double nivelRuido) {
    if (nivelRuido < 65) {
      return Colors.green;
    } else if (nivelRuido < 85) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  IconData getNoiseLevelIcon(double nivelRuido) {
    if (nivelRuido < 65) {
      return Icons.volume_up;
    } else if (nivelRuido < 85) {
      return Icons.volume_mute;
    } else {
      return Icons.headset_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa y Reportes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.teal,
      ),
      body: Row(
        children: [
          // Panel izquierdo: Mapa
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
              ),
              child: MapStartController(),
            ),
          ),

          // Panel derecho: Reportes
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: isLoadingReports
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: webReportsController.reportData.length,
                          itemBuilder: (context, index) {
                            var report = webReportsController.reportData[index];
                            double nivelRuido =
                                double.tryParse(report['Nivel_Ruido'].toString()) ?? 0.0;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(
                                  getNoiseLevelIcon(nivelRuido),
                                  color: getNoiseLevelColor(nivelRuido),
                                  size: 30,
                                ),
                                title: Text(
                                  'Nivel de Ruido: ${nivelRuido.toStringAsFixed(1)} dB',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'Fecha: ${report['Fecha']}\nHora: ${report['Hora']}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                onTap: () {
                                  print('Detalles del reporte: ${report['Id_Medida']}');
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
