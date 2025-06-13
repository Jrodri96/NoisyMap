import 'package:appruido/controllers/Reports_controller.dart';
import 'package:flutter/material.dart';

class ReportsView extends StatefulWidget {
  @override
  _ReportsViewState createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  bool isLoading = true;
  final ReportsController reportsController = ReportsController();

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void fetchReports() async {
    await reportsController.fetchReports();
    setState(() {
      isLoading = false;
    });
  }

  // Método para determinar el color del ícono basado en el nivel de ruido
  Color getMarkerColor(double nivelRuido) {
    if (nivelRuido < 65) {
      return Colors.green; // Nivel seguro
    } else if (nivelRuido < 85) {
      return Colors.yellow; // Nivel moderado
    } else {
      return Colors.red; // Nivel alto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reportes de Ruido',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : reportsController.reportData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'No se encontraron reportes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    itemCount: reportsController.reportData.length,
                    itemBuilder: (context, index) {
                      var report = reportsController.reportData[index];
                      double nivelRuido = (report['Nivel_Ruido'] as num).toDouble();

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getMarkerColor(nivelRuido),
                            child: Icon(Icons.bar_chart, color: Colors.white),
                          ),
                          title: Text(
                            'Nivel de Ruido: ${nivelRuido.toStringAsFixed(1)} dB',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            'Fecha: ${report['Fecha']} - Hora: ${report['Hora']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Icon(
                            Icons.location_on,
                            color: getMarkerColor(nivelRuido), // Color del ícono basado en el nivel de ruido
                          ),
                          onTap: () {
                            // Acciones al seleccionar un reporte
                            print('Detalles del reporte: ${report['Id_Medida']}');
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
