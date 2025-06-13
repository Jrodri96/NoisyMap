import 'package:flutter/material.dart';
import 'package:appruido/controllers/signup_controller.dart'; // Ruta correcta del controlador

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      birthdateController.text = "${picked.toLocal()}".split(' ')[0]; // Formato YYYY-MM-DD
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'Número de cédula (ID)',
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
              ),
            ),
            TextField(
              controller: userController,
              decoration: InputDecoration(
                labelText: 'Usuario', // clave primaria
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
              ),
              obscureText: true,
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
              ),
            ),
            TextField(
              controller: birthdateController,
              decoration: InputDecoration(
                labelText: 'Fecha de nacimiento',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context), // Abre el DatePicker
                ),
              ),
              readOnly: true, // Evitar que el usuario escriba directamente
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Dirección',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                if (idController.text.isEmpty || nameController.text.isEmpty ||
                    userController.text.isEmpty || passwordController.text.isEmpty ||
                    phoneController.text.isEmpty || birthdateController.text.isEmpty ||
                    addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, complete todos los campos.')),
                  );
                  return;
                }

                setState(() {
                  _isLoading = true;
                });

                int result = await SignUpController().signUp(
                  id: idController.text,
                  nombre: nameController.text,
                  user: userController.text,
                  password: passwordController.text,
                  telefono: phoneController.text,
                  fechaNacimiento: birthdateController.text,
                  direccion: addressController.text,
                );

                setState(() {
                  _isLoading = false;
                });

                if (result == 1) {
                  // Registro exitoso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registro exitoso')),
                  );
                } else if (result == 2) {
                  // ID ya existe
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('El ID ya existe')),
                  );
                } else if (result == 3) {
                  // Usuario ya existe
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('El usuario ya existe')),
                  );
                } else {
                  // Fallo en el registro
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fallo en el registro')),
                  );
                }
              },
              child: _isLoading ? CircularProgressIndicator() : Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
