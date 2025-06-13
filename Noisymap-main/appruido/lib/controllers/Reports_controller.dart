import 'dart:convert';
import 'package:appruido/controllers/login_controller.dart';
import 'package:http/http.dart' as http;

class ReportsController {
  final String apiUrl = 'http://192.168.1.9/apis/Api_reports.php';  // Cambia esta URL según la direccion ipv4
  List<dynamic> _reportData = [];  // Lista privada para almacenar los reportes

  // Getter para obtener los reportes
  List<dynamic> get reportData => _reportData;

  // Función para obtener los reportes desde la API
  Future<void> fetchReports() async {
    try {
      // Asegúrate de obtener el ID del usuario desde el LoginController
      int? userId = LoginController.userId;  // Obtén el userId guardado en el LoginController
      if (userId == null) {
        print('No se ha encontrado el ID de usuario');
        return;
      }

      final response = await http.get(
        Uri.parse('$apiUrl?user_id=$userId'),  // Pasa el user_id a la API
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 1) {
          _reportData = responseData['data'];  // Almacena los datos en _reportData
        } else {
          print('Error al obtener los reportes: ${responseData['message']}');
        }
      } else {
        print('Error al conectar con la API: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener los reportes: $e');
    }
  }
}
