import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  _ManageAccountsScreen createState() => _ManageAccountsScreen();
}

class _ManageAccountsScreen extends State<ManageAccountsScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _careerController = TextEditingController();
  String role = 'student';
  String semestre = 'Primero';
  String credyTipe = 'Contado';
  String shareNumber = '1';
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

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _idNumberController.text.isEmpty ||
        _careerController.text.isEmpty ||
        semestre.isEmpty ||
        credyTipe.isEmpty ||
        shareNumber.isEmpty ||
        role.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor completa todos los campos';
      });
      return;
    }
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _idNumberController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': _emailController.text,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'idNumber': _idNumberController.text,
          'career': _careerController.text,         
          'semestre': semestre,
          'credy_tipe': credyTipe,
          'share_number': shareNumber,
          'role': role,
          'isFirstLogin': true,
          'status': true,
          'information_input': DateTime.now(),
          'information_output': '',
          'created': usuarioProvider.userData!['firstName'].toString(),
          'update':'',
          'delete':'',
        });
        await sendWelcomeEmail(
            _emailController.text, _firstNameController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro Satisfactorio')),
        );
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro Satisfactorio')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> sendWelcomeEmail(String email, String name) async {
    final smtpServer = gmail('grm.vera@yavirac.edu.ec', 'Geovanny18Vera19');
    // Reemplaza con tus credenciales de Gmail u otro servidor SMTP
    final message = Message()
      ..from = const Address('grm.vera@yavirac.edu.ec', 'Rodolfo')
      ..recipients.add(email)
      ..subject = '¡Bienvenido a Unibe Control de Acceso!'
      ..text =
          'Hola $name,\n\n¡Nos complace darte la bienvenida a [Nombre de tu aplicación]!\n\nTu correo electrónico registrado es: $email\n\nPuedes iniciar sesión en [Enlace a tu aplicación] para comenzar a disfrutar de todas las funciones.\n\n¡Recuerda que la clave es tu numero de cedula\n\nAtentamente,\nEl equipo de Unibe';
    try {
      final sendReport = await send(message, smtpServer);
      print('Mensaje enviado: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('Error al enviar el correo electrónico: ${e.toString()}');
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
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
                decoration:
                    const InputDecoration(labelText: 'Número de Cédula'),
              ),
              TextField(
                controller: _careerController,
                decoration: const InputDecoration(labelText: 'Carrera'),
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: semestre,
                    onChanged: (String? newValue) {
                      setState(() {
                        semestre = newValue!;
                      });
                    },
                    items: <String>[
                      'Primero',
                      'Segundo',
                      'Tercero',
                      'Cuarto',
                      'Quinto',
                      'Sexto',
                      'Séptimo',
                      'Octavo',
                      'Noveno'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: credyTipe,
                    onChanged: (String? newValue) {
                      setState(() {
                        credyTipe = newValue!;
                      });
                    },
                    items: <String>['Contado', 'Credito']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  if (credyTipe == 'Credito')
                    DropdownButton<String>(
                      value: shareNumber,
                      onChanged: (String? newValue) {
                        setState(() {
                          shareNumber = newValue!;
                        });
                      },
                      items: <String>[
                        '1',
                        '2',
                        '3',
                        '4'
                      ] // Puedes agregar más opciones
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                ],
              ),
              DropdownButton<String>(
                value: role,
                onChanged: (String? newValue) {
                  setState(() {
                    role = newValue!;
                  });
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
                child: const Text('Crear Usuario'),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
