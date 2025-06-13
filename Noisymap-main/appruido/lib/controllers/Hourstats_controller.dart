import 'dart:convert';
import 'package:http/http.dart' as http;

class HourStatsController {
  final String apiUrl = 'http://192.168.1.9/apis/Api_Filtroporhora.php'; // Cambia esta URL según la direccion ipv4

  /// Realiza la solicitud al API y devuelve el promedio de ruido por hora
  Future<List<Map<String, dynamic>>> fetchHourlyStats() async {
    print('Iniciando solicitud para estadísticas por hora.');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      print('Respuesta recibida con código: ${response.statusCode}');
      print('Contenido de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 1 && responseData['hourly'] != null) {
          print('Datos procesados correctamente: ${responseData['hourly']}');
          return _processHourlyData(responseData['hourly']);
        } else {
          print('Error en los datos: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Datos no válidos.');
        }
      } else {
        print('Error en el servidor: Código ${response.statusCode}');
        throw Exception('Error en el servidor. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción durante la solicitud: $e');
      throw Exception('Error al realizar la solicitud: $e');
    }
  }

  /// Completa las horas faltantes con valores predeterminados (nivel de ruido 0)
  List<Map<String, dynamic>> _processHourlyData(List<dynamic> hourlyData) {
    print('Procesando datos horarios originales: $hourlyData');

    // Convertir datos en un mapa para acceso rápido
    final Map<String, double> dataMap = {};
    for (var entry in hourlyData) {
      final hour = entry['hora'] as String;
      final noiseLevel = entry['nivel_ruido'] as double;
      dataMap[hour] = noiseLevel;
      print('Hora procesada: $hour -> Nivel Ruido: $noiseLevel');
    }

    // Generar datos completos con horas faltantes
    final List<Map<String, dynamic>> completeHourlyData = [];
    for (int i = 0; i < 24; i++) {
      final hour = '${i.toString().padLeft(2, '0')}:00';
      completeHourlyData.add({
        'hora': hour,
        'nivel_ruido': dataMap[hour] ?? 0, // Nivel de ruido o 0 si no existe
      });
      print('Validación para hora $hour -> Nivel Ruido: ${dataMap[hour] ?? 0}');
    }

    print('Datos horarios procesados: $completeHourlyData');
    return completeHourlyData;
  }
}
