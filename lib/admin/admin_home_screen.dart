import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:unibe_app_control/Widget/botton_navigaton_bart.dart';
import 'package:unibe_app_control/admin/manage_accounts_admin.dart';
import '../login/users_provider.dart';
import '../login/login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widget/user_table.dart';
import '../Widget/user_disabled_table.dart';
import '../Widget/user_student.dart';
import 'manage_accounts_student.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool light = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Se añade el SingleChildScrollView
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showCreatedUsersDialog(context);
                  },
                  child: const Text('Crear Usuario'),
                ),
                ElevatedButton(
                  onPressed: () => uploadExcel(context),
                  child: const Text('Cargar Excel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showDisabledUsersDialog(context);
                  },
                  child: const Text('Usuarios Inabilitados'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar por ID',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Switch.adaptive(
              value: light,
              onChanged: (bool value) {
                setState(() {
                  light = value;
                });
              },
            ),
            const SizedBox(height: 20),
            if (light)
              UserTable(searchController: _searchController)
            else
              const UserStudent(),
          ],
        ),
      ),
      bottomNavigationBar: const BottonNavigatonBart(),
    );
  }

  void _showDisabledUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usuarios Desactivados'),
          content: const SingleChildScrollView(
            child: UserDisabledTable(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatedUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tipo de Usuario'),
          content: const Text('¿Qué tipo de usuario deseas crear?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Estudiante'),
              onPressed: () {
                // Navegar a la pantalla de creación de estudiante
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageAccountsStudent(),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Administrador'),
              onPressed: () {
                // Navegar a la pantalla de creación de administrador
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ManageAccountsAdmin(), // Reemplaza con la pantalla correcta
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

Future<void> uploadExcel(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result != null && result.files.isNotEmpty) {
    var bytes = result.files.single.bytes;
    if (bytes != null) {
      var excel = Excel.decodeBytes(bytes);
      String fileName = result.files.single.name;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Subiendo Archivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fileName),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
      try {
        for (var table in excel.tables.keys) {
          List<List<Data?>> rows = excel.tables[table]!.rows;
          for (var row in rows.skip(1)) {
            var email = row[0]?.value;
            var firstName = row[1]?.value;
            var lastName = row[2]?.value;
            var idNumber = row[3]?.value;
            var career = row[4]?.value;
            var role = row[5]?.value;
            var semestre = row[6]?.value;
            var credyTipe = row[7]?.value;
            var shareNumber = row[8]?.value;
            var password = idNumber;
            var informationInput = DateTime.now();
            var informationOutput = '';
            var created = Provider.of<UsuarioProvider>(context, listen: false);
            var update = '';
            var delete = '';

            if (email != null &&
                password != null &&
                firstName != null &&
                lastName != null &&
                idNumber != null &&
                career != null &&
                role != null &&
                semestre != null &&
                credyTipe != null &&
                shareNumber != null) {
              try {
                UserCredential userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email.toString(),
                  password: password.toString(),
                );

                User? user = userCredential.user;

                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .set({
                    'email': email.toString(),
                    'firstName': firstName.toString(),
                    'lastName': lastName.toString(),
                    'idNumber': idNumber.toString(),
                    'career': career.toString(),
                    'role': role.toString(),
                    'semestre': semestre.toString(),
                    'credy_tipe': credyTipe.toString(),
                    'share_number': shareNumber.toString(),
                    'information_input': informationInput,
                    'information_output': informationOutput,
                    'isFirstLogin': true,
                    'status': true,
                    'created': created.userData!['firstName'].toString(),
                    'update': update,
                    'delete': delete,
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al crear usuario $email: $e')),
                );
                Navigator.pop(context);
              }
            }
          }
        } // Mostrar SnackBar con mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuarios creados con éxito')),
        );
      } catch (e) {
        // Mostrar SnackBar con mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formato de archivo inválido.')),
        );
      } finally {
        // Cerrar el AlertDialog
        Navigator.pop(context);
      }
    } else {
      // Mostrar SnackBar indicando que no se seleccionó ningún archivo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha seleccionado ningún archivo')),
      );
    }
  } else {
    // Manejar el caso en que 'result' o 'files' es nulo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se ha seleccionado ningún archivo.')),
    );
  }
}
