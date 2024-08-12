import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../admin/form_settings.dart';
import 'package:date_picker_plus/date_picker_plus.dart';

class ManageAccounts extends StatefulWidget {
  const ManageAccounts({super.key});

  @override
  _ManageAccounts createState() => _ManageAccounts();
}

class _ManageAccounts extends State<ManageAccounts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FromSettings(),
                ),
              );
              if (result == true) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Widget>>(
          future: obtenerCamposFormulario(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        border: OutlineInputBorder(), // Mejora el diseño
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _idNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Cédula',
                        border: OutlineInputBorder(), // Mejora el diseño
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...snapshot.data!, // Agrega los campos de Firebase aquí
                    DropdownButtonFormField<String>(
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
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Mejora el diseño
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 400,
                      height: 400,
                      child: RangeDatePicker(
                        centerLeadingDate: true,
                        minDate: DateTime(2020, 10, 10),
                        maxDate: DateTime(2024, 10, 30),
                        onRangeSelected: (value) {
                          // Handle selected range
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => crearUsuario(
                          context), // Envuelve la llamada en una función anónima
                      child: const Text('Crear Usuario'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

Future<List<Widget>> obtenerCamposFormulario() async {
  List<Widget> campos = [];
  _textControllers = [];

  CollectionReference configuracion =
      FirebaseFirestore.instance.collection('form_settings');
  QuerySnapshot snapshot =
      await configuracion.where('status', isEqualTo: true).get();
  for (var doc in snapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['tipe_entry'] == 'texto') {
      var controller = TextEditingController(); // Crear un controlador
      _textControllers.add({
        'label': data['label'],
        'controller': controller
      }); // Guardar el controlador en la lista
      campos.add(
        Padding(
          padding: const EdgeInsets.only(
              bottom: 16.0), // Añade espaciado entre los campos
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: data['label'],
              border: OutlineInputBorder(), // Mejora el diseño
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      );
    } else if (data['tipe_entry'] == 'dropdown') {
      List<String> options =
          (data['options'] as List).map((e) => e.toString()).toList();
      campos.add(
        Padding(
          padding: const EdgeInsets.only(
              bottom: 16.0), // Añade espaciado entre los campos
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['label'], // Muestra el label
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8), // Espaciado entre label y dropdown
              DropdownButtonFormField<String>(
                value: options[
                    0], // Usa el primer elemento de la lista de opciones
                onChanged: (String? newValue) {
                  // Lógica para actualizar el valor seleccionado
                },
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // Mejora el diseño
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  return campos;
}

Map<String, dynamic> obtenerValoresCampos() {
  Map<String, dynamic> valores = {};
  for (var item in _textControllers) {
    String label = item['label']; // Obtener el label del item
    String value = item['controller'].text; // Obtener el valor del controlador
    valores[label] = value;
  }
  return valores;
}

List<Map<String, dynamic>> _textControllers = [];
final _auth = FirebaseAuth.instance;
final _emailController = TextEditingController();
final _idNumberController = TextEditingController();
String _errorMessage = '';
String role = 'student';

bool _isValidEmail(String email) {
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegExp.hasMatch(email);
}

Future<void> crearUsuario(BuildContext context) async {
  final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);

  if (!_isValidEmail(_emailController.text)) {
    return;
  }
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _idNumberController.text,
    );
    User? user = userCredential.user;
    if (user != null) {
      Map<String, dynamic> valoresCampos = obtenerValoresCampos();
      await FirebaseFirestore.instance.collection('users_student').add({
        'email': _emailController.text,
        'idNumber': _idNumberController.text,
        'role': role,
        'isFirstLogin': true,
        'status': true,
        'information_input': DateTime.now(),
        'information_output': '',
        'created': usuarioProvider.userData!['firstName'].toString(),
        'update': '',
        'delete': '',
        // Agrega aquí los demás campos del formulario
      }).then((value) {
        value.update(valoresCampos); // Usar update para agregar los valores
      });
    }
    /*await sendWelcomeEmail(_emailController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro Satisfactorio')),
    );
    Navigator.pop(context);*/

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro Satisfactorio')),
    );
    Navigator.pop(context);
  } catch (e) {
    // Mostrar un mensaje de error al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al crear el usuario: $e')),
    );
  }
}

Future<void> sendWelcomeEmail(String email) async {
  final smtpServer = gmail('grm.vera@yavirac.edu.ec', 'Geovanny18Vera19');
  // Reemplaza con tus credenciales de Gmail u otro servidor SMTP
  final message = Message()
    ..from = const Address('grm.vera@yavirac.edu.ec', 'Rodolfo')
    ..recipients.add(email)
    ..subject = '¡Bienvenido a Unibe Control de Acceso!'
    ..text =
        'Hola,\n\n¡Nos complace darte la bienvenida a [Nombre de tu aplicación]!\n\nTu correo electrónico registrado es: $email\n\nPuedes iniciar sesión en [Enlace a tu aplicación] para comenzar a disfrutar de todas las funciones.\n\n¡Recuerda que la clave es tu numero de cedula\n\nAtentamente,\nEl equipo de Unibe';
  try {
    final sendReport = await send(message, smtpServer);
    print('Mensaje enviado: ${sendReport.toString()}');
  } on MailerException catch (e) {
    print('Error al enviar el correo electrónico: ${e.toString()}');
  }
}
