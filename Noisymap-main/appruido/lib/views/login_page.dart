import 'package:appruido/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = LoginController();
  bool isLoading = false;

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido a Noisy Map!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Usuario',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                        showErrorDialog('Por favor, complete todos los campos.');
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      int result = await loginController.login(
                        user: emailController.text,
                        password: passwordController.text,
                      );

                      setState(() {
                        isLoading = false;
                      });

                      if (result == 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        String errorMessage;
                        if (result == 0) {
                          errorMessage = 'Credenciales inválidas.';
                        } else if (result == -1) {
                          errorMessage = 'Error en la conexión. Intente nuevamente.';
                        } else if (result == 'missing_fields') {
                          errorMessage = 'Faltan campos en la solicitud.';
                        } else {
                          errorMessage = 'Error al iniciar sesión. Intente nuevamente más tarde.';
                        }
                        print('Resultado de inicio de sesión: $result');
                        showErrorDialog(errorMessage);
                      }
                    },
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Iniciar Sesión'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('No tienes una cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
