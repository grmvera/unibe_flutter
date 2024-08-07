
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../login/login_screen.dart';
import '../admin/admin_home_screen.dart';
import 'package:provider/provider.dart';
import '../login/users_provider.dart';
import '../login/change_password.dart';
import '../Widget/qr_studen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    usuarioProvider.fetchUserData().then((_) {
      if (usuarioProvider.userData != null &&
          usuarioProvider.userData!['isFirstLogin'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChangePassword()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
      body: Center(
        child: usuarioProvider.userData != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Bienvenido a la Unibe control',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Nombre: ${usuarioProvider.userData!['firstName']}'),
                  Text('Apellido: ${usuarioProvider.userData!['lastName']}'),
                  Text('Rol: ${usuarioProvider.userData!['role']}'),
                  
                  if (usuarioProvider.userData!['role'] == 'student')
                    QrCodeWidget(studentEmail: usuarioProvider.userData!['email'], studentId: usuarioProvider.userData!['idNumber'], studentName: usuarioProvider.userData!['firstName']),
                  const SizedBox(height: 20),

                  
                  if (usuarioProvider.userData!['role'] == 'admin')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AdminHomeScreen()),
                        );
                      },
                      child: const Text('Administrador'),
                    ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
