import 'dart:convert';
import 'package:http/http.dart' as http;

class WebReportsController {
  final String apiUrl = 'http://192.168.1.9/apis/Api_Registrosruido.php';  // Cambia esta URL según la direccion ipv4
  List<dynamic> _reportData = [];  // Lista privada para almacenar los reportes

  // Getter para obtener los reportes
  List<dynamic> get reportData => _reportData;

  // Función para obtener todos los reportes desde la API
  Future<void> fetchReports() async {
    try {
      print("Iniciando solicitud a la API: $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),  
      );

      print("Respuesta de la API recibida: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Respuesta exitosa de la API");
        final responseData = jsonDecode(response.body);
        
        // Verificamos que la respuesta tenga el formato esperado
        if (responseData is Map<String, dynamic>) {
          if (responseData['status'] == 1) {
            print("Datos recibidos con éxito, procesando...");
            _reportData = responseData['data'];  // Almacena los datos en _reportData
          } else {
            print('Error al obtener los reportes: ${responseData['message']}');
          }
        } else {
          print("Error: La respuesta de la API no tiene el formato esperado.");
        }
      } else {
        print('Error al conectar con la API. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener los reportes: $e');
    }
  }
}
