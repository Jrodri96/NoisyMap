import 'dart:convert';
import 'package:http/http.dart' as http;

class DateController {
  final String apiUrl = 'http://192.168.1.9/apis/Api_Filtroporfecha.php'; // Cambia esta URL según la direccion ipv4

  /// Realiza una solicitud a la API para obtener estadísticas de una fecha específica.
  Future<Map<String, dynamic>> fetchStatsByDate(String fecha) async {
    print('Iniciando solicitud para estadísticas de la fecha: $fecha');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fecha': fecha}),
      );

      print('Respuesta recibida con código: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Datos recibidos de la API: $responseData');

        if (responseData['status'] == 1 && responseData['data'] != null) {
          // Procesar datos para incluir horas faltantes
          final hourlyData = _processHourlyData(responseData['data']['hourly']);
          return {
            'status': 1,
            'summary': responseData['data']['summary'] ?? {},
            'hourly': hourlyData,
          };
        } else if (responseData['status'] == 0) {
          // Si no hay datos para la fecha seleccionada
          return {
            'status': 0,
            'message': responseData['message'] ?? 'No hay registros disponibles para la fecha seleccionada.',
          };
        } else {
          // Caso de error inesperado
          return {
            'status': 0,
            'message': 'La API no devolvió datos válidos.',
          };
        }
      } else {
        print('Error en el servidor: ${response.statusCode}');
        return {
          'status': -1,
          'message': 'Error en el servidor. Código: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Excepción durante la solicitud: $e');
      return {
        'status': -1,
        'message': 'Excepción: $e',
      };
    }
  }

  /// Procesa los datos horarios para incluir horas faltantes con valores predeterminados.
  List<Map<String, dynamic>> _processHourlyData(List<dynamic> hourlyData) {
    print('Procesando datos horarios originales: $hourlyData');

    // Crear un mapa para acceder rápidamente a los datos existentes
    final Map<String, double> dataMap = {};
    for (var entry in hourlyData) {
      final hour = entry['hora'] as String;
      final noiseLevel = entry['nivel_ruido'] as double;
      dataMap[hour] = noiseLevel;
    }

    // Crear una lista completa de horas con valores predeterminados
    final List<Map<String, dynamic>> completeHourlyData = [];
    for (int i = 0; i < 24; i++) {
      final hour = '${i.toString().padLeft(2, '0')}:00';
      completeHourlyData.add({
        'hora': hour,
        'nivel_ruido': dataMap[hour] ?? 0, // Usar el nivel de ruido o 0 si no existe
      });
    }

    print('Datos horarios procesados: $completeHourlyData');
    return completeHourlyData;
  }
}
