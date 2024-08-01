import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../login/users_provider.dart';
import '../login/login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_accounts_screen.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('administracion de usuarios'),
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
              debugPrint('yo estube aqui debug');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Página Administrativa',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageAccountsScreen(),
                  ),
                );
                print('me voy a gestion');
              },
              child: const Text('Gestionar Cuentas'),
            ),
            ElevatedButton(
              onPressed: () => uploadExcel(context),
              child: const Text('Cargar Excel'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> uploadExcel(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );
  print(result);

  if (result != null && result.files != null && result.files.isNotEmpty) {
    var bytes = result.files.single.bytes;
    if (bytes != null) {
      var excel = Excel.decodeBytes(bytes);
      // Mostrar AlertDialog con mensaje de "Subiendo archivo..."
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
        // ... procesar el archivo Excel ...
        print(excel.tables.keys);

        for (var table in excel.tables.keys) {
          List<List<Data?>> rows = excel.tables[table]!.rows;
          for (var row in rows.skip(1)) {
            var email = row[0]?.value;
            var firstName = row[1]?.value;
            var lastName = row[2]?.value;
            var idNumber = row[3]?.value;
            var career = row[4]?.value;
            var role = row[5]?.value;
            var password = idNumber;


            if (email != null &&
                password != null &&
                firstName != null &&
                lastName != null &&
                idNumber != null &&
                career != null &&
                role != null) {
              print('Creando usuario con email: $email');
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
                    'isFirstLogin': true,
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