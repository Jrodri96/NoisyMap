import 'dart:convert';
import 'package:http/http.dart' as http;

class HeatMapController {
  final String apiUrl = 'http://192.168.1.9/apis/Api_Heatmap.php'; // Cambia esta URL según la direccion ipv4
  final double proximityThreshold = 0.01; // Umbral de proximidad en grados

  /// Obtiene y procesa los datos del mapa de calor agrupados por proximidad
  Future<List<Map<String, dynamic>>> fetchClusteredHeatMapData(String fecha, {int? hora}) async {
    try {
      // Construir el cuerpo de la solicitud, omitiendo `hora` si es null
      final Map<String, dynamic> bodyData = {'fecha': fecha};
      if (hora != null && hora > 0) {
        bodyData['hora'] = hora.toString();
      } else if (hora == 0) {
        // Si la hora es 0 (medianoche), ajustarla a 00:01 para diferenciar de "sin hora"
        bodyData['hora'] = "00:01";
      }

      final body = jsonEncode(bodyData);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 1 && responseData['data'] != null) {
          return _clusterHeatMapData(responseData['data']);
        } else {
          print('No se encontraron datos: ${responseData['message']}');
          return [];
        }
      } else {
        throw Exception('Error en el servidor: Código ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener datos del API: $e');
      throw Exception('Error al obtener datos del mapa de calor');
    }
  }

  /// Agrupa los datos del mapa de calor en áreas cercanas y calcula promedios
  List<Map<String, dynamic>> _clusterHeatMapData(List<dynamic> data) {
    final List<Map<String, dynamic>> clusters = [];

    for (var entry in data) {
      final double lat = entry['lat'];
      final double lng = entry['lng'];
      final double nivelRuido = entry['nivelRuido'];

      bool addedToCluster = false;

      // Intenta agregar este punto a un cluster existente
      for (var cluster in clusters) {
        double clusterLat = cluster['lat'];
        double clusterLng = cluster['lng'];

        if (_isWithinProximity(lat, lng, clusterLat, clusterLng)) {
          // Actualiza los promedios del cluster
          cluster['lat'] = (cluster['lat'] * cluster['count'] + lat) / (cluster['count'] + 1);
          cluster['lng'] = (cluster['lng'] * cluster['count'] + lng) / (cluster['count'] + 1);
          cluster['nivelRuido'] = (cluster['nivelRuido'] * cluster['count'] + nivelRuido) / (cluster['count'] + 1);
          cluster['count'] += 1;
          addedToCluster = true;
          break;
        }
      }

      // Si no pertenece a ningún cluster, crea uno nuevo
      if (!addedToCluster) {
        clusters.add({
          'lat': lat,
          'lng': lng,
          'nivelRuido': nivelRuido,
          'count': 1, // Para rastrear cuántos puntos tiene el cluster
        });
      }
    }

    // Elimina el campo `count` antes de devolver los clusters
    return clusters.map((cluster) {
      return {
        'lat': cluster['lat'],
        'lng': cluster['lng'],
        'nivelRuido': cluster['nivelRuido'],
      };
    }).toList();
  }

  /// Verifica si dos puntos están dentro del umbral de proximidad
  bool _isWithinProximity(double lat1, double lng1, double lat2, double lng2) {
    double latDiff = (lat1 - lat2).abs();
    double lngDiff = (lng1 - lng2).abs();
    return latDiff <= proximityThreshold && lngDiff <= proximityThreshold;
  }
}
