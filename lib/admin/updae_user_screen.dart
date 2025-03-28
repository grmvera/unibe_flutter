import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unibe_app_control/Widget/student_view.dart';
import '../Widget/custom_app_bar.dart';
import '../Widget/custom_bottom_navigation_bar.dart';
import '../Widget/custom_drawer.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';

class UpdateUserScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UpdateUserScreen({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController idNumberController;
  late TextEditingController emailController;
  int _selectedIndex = 0;
  bool isBlocked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: widget.userData['firstName'] ?? '');
    lastNameController =
        TextEditingController(text: widget.userData['lastName'] ?? '');
    idNumberController =
        TextEditingController(text: widget.userData['idNumber'] ?? '');
    emailController =
        TextEditingController(text: widget.userData['email'] ?? '');
    isBlocked = widget.userData['status'] == false;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    idNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de restablecimiento enviado.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al enviar correo de restablecimiento: $e')),
      );
    }
  }

  Future<void> bloquearUsuario(String userId) async {
    final shouldBlock = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Bloqueo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Está seguro de bloquear al usuario ${firstNameController.text} ${lastNameController.text}?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    if (shouldBlock == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'status': false,
          'information_output': DateTime.now(),
        });
        setState(() {
          isBlocked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario bloqueado exitosamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al bloquear el usuario: $e')),
        );
      }
    }
  }

  Future<void> desbloquearUsuario(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'status': true,
        'information_output': '',
      });
      setState(() {
        isBlocked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario desbloqueado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al desbloquear el usuario: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> updateEmailInAuth(String userId, String newEmail) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-controlacceso-403b0.cloudfunctions.net/updateUserEmail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': userId,
          'newEmail': newEmail,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Correo actualizado exitosamente en Authentication.')),
        );
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el correo: $e')),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final usuarioProvider = Provider.of<UsuarioProvider>(context);
  final isStudent = widget.userData['role'] == 'estudiante';

  return Scaffold(
    key: scaffoldKey,
    appBar: CustomAppBar(
      userName: usuarioProvider.userData?['firstName'] ?? 'Usuario',
      userRole: usuarioProvider.userData?['role'] ?? 'Sin Rol',
      scaffoldKey: scaffoldKey,
    ),
    endDrawer: CustomDrawer(userData: usuarioProvider.userData!),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actualizar Usuario',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: isBlocked ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isBlocked ? 'Bloqueado' : 'Activo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idNumberController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Cédula',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botones con estilo mejorado
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          bloquearUsuario(widget.userId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Bloquear'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBlocked
                            ? () {
                                desbloquearUsuario(widget.userId);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isBlocked ? Colors.green : Colors.grey[400],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Desbloquear'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isStudent)
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final querySnapshot = await FirebaseFirestore.instance
                          .collection('users')
                          .where('idNumber',
                              isEqualTo: widget.userData['idNumber'])
                          .get();

                      if (querySnapshot.docs.isNotEmpty) {
                        final userDoc = querySnapshot.docs.first;
                        final updatedUserData = {
                          ...widget.userData,
                          'docId': userDoc.id,
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentView(
                              userData: updatedUserData,
                              showAppBar: true,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Usuario no encontrado en la base de datos.'),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al buscar el usuario: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Ver Carnet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    String email = emailController.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'El campo de correo no puede estar vacío')),
                      );
                      return;
                    }
                    await resetPassword(email);
                  },
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Restablecer Contraseña'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            String newEmail = emailController.text.trim();
                            if (newEmail.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'El campo de correo no puede estar vacío')),
                              );
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }

                            await updateEmailInAuth(
                                widget.userId, newEmail);

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.userId)
                                .update({
                              'firstName': firstNameController.text.trim(),
                              'lastName': lastNameController.text.trim(),
                              'email': newEmail,
                            });

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error al actualizar el usuario: $e')),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Guardando...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : const Text('Guardar Cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      userRole: usuarioProvider.userData!['role'],
    ),
  );
}

}
