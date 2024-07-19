import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

        // Crear documento en Firestore sin verificar permisos
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'idNumber': idNumberController.text,
          'career': careerController.text,
          'role': role,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario creado con éxito')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el usuario: $e')));
    }
  }
}
