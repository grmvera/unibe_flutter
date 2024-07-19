/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';


class ManageAccountsScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController careerController = TextEditingController();
  String role = 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Cuentas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: idNumberController,
              decoration: const InputDecoration(labelText: 'Número de Cédula'),
            ),
            TextField(
              controller: careerController,
              decoration: const InputDecoration(labelText: 'Carrera'),
            ),
            DropdownButton<String>(
              value: role,
              onChanged: (String? newValue) {
                role = newValue!;
              },
              items: <String>['admin', 'student']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () => createUser(context),
              child: const Text('Crear Usuario'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createUser(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text);

      User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid;
        /*
        // Crear documento en Firestore sin verificar permisos
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'idNumber': idNumberController.text,
          'career': careerController.text,
          'role': role,
        });*/

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario creado con éxito')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el usuario: $e')));
    }
  }
}
*/


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  _ManageAccountsScreen createState() => _ManageAccountsScreen();
}

class _ManageAccountsScreen extends State<ManageAccountsScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _careerController = TextEditingController();
  String role = '';
  String _errorMessage = '';

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _register() async {
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);

    if (usuarioProvider.userData?['role'] != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No cuentas con los permisos necesarios para realizar esta acción')),
      );
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      setState(() {
        _errorMessage = 'Por favor ingresa un correo electrónico válido';
      });
      return;
    }

    if (_passwordController.text.length < 8) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 8 caracteres';
      });
      return;
    }

    if(_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _idNumberController.text.isEmpty || _careerController.text.isEmpty){
      setState(() {
        _errorMessage = 'oooooo';
      });
      return;
    }

    // Si se cumplen todas las condiciones, proceder con el registro
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        /*firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        idNumber: _idNumberController.text,
        career: _careerController.text,
        role: role,*/
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro Satisfactorio')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _idNumberController,
              decoration: const InputDecoration(labelText: 'Número de Cédula'),
            ),
            TextField(
              controller: _careerController,
              decoration: const InputDecoration(labelText: 'Carrera'),
            ),
            DropdownButton<String>(
              value: role,
              onChanged: (String? newValue) {
                role = newValue!;
              },
              items: <String>['admin', 'student']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Registrarse'),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: const TextStyle(color: Color.fromARGB(255, 54, 244, 244)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
