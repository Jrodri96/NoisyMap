import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginController {
  final String apiUrl = 'http://192.168.1.9/apis/Api_Login.php'; // Cambia esta URL según la direccion ipv4

  // Variable global para almacenar el ID del usuario logueado
  static int? userId;

  Future<int> login({required String user, required String password}) async {
    print('Iniciando proceso de inicio de sesión...');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'User': user,
          'Password': password,
        }),
      );

      print('Respuesta recibida con código: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Datos de respuesta: $responseData');

        if (responseData['status'] == 1) {
          // Convertir directamente el ID a int
          userId = responseData['ID'] is int
              ? responseData['ID'] // Si ya es un int, lo usamos directamente
              : int.parse(responseData['ID'].toString()); // Si es un string, lo convertimos a int

          print('Inicio de sesión exitoso. ID del usuario: $userId');
          return responseData['status'];
        } else {
          print('Inicio de sesión fallido: ${responseData['message']}');
          return responseData['status']; // Retorna el estado de error
        }
      } else {
        print('Error en la respuesta del servidor: ${response.statusCode}');
        return -1;
      }
    } catch (e) {
      print('Excepción durante el inicio de sesión: $e');
      return -1; // Retorna -1 en caso de error
    }
  }
}
