import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpController {
  final String apiUrl = 'http://192.168.1.9/apis/Api_SignUp.php'; // Cambia esta URL según la direccion ipv4

  Future<int> signUp({
    required String id,
    required String nombre,
    required String user,
    required String password,
    required String telefono,
    required String fechaNacimiento,
    required String direccion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ID': id,
          'Nombre': nombre,
          'User': user,
          'Password': password,
          'Telefono': telefono,
          'Fecha_Nacimiento': fechaNacimiento,
          'Direccion': direccion,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Verificar que la respuesta sea un objeto y contenga 'status'
        if (responseData is Map<String, dynamic> && responseData.containsKey('status')) {
          if (responseData['status'] == 'success') {
            return 1; // Registro exitoso
          } else if (responseData['message'] == 'El ID ya existe') {
            return 2; // ID ya existe
          } else if (responseData['message'] == 'El usuario ya existe') {
            return 3; // Usuario ya existe
          }
        }
      } else {
        print('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // Manejo de excepciones
    }

    return 0; // Error en el registro
  }
}
