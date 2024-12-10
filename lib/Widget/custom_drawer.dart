import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unibe_app_control/login/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;

  const CustomDrawer({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cabecera del Drawer
          UserAccountsDrawerHeader(
            accountName: Text(
              '${userData['firstName']} ${userData['lastName']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userData['email'] ?? 'Correo no registrado',
              style: const TextStyle(fontSize: 16),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.black,
              ),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1225F5),
            ),
          ),
          // Opciones del Drawer
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(
                      'Carrera: ${userData['career'] ?? 'Sin carrera registrada'}'),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(
                      'Semestre: ${userData['semestre'] ?? 'Sin semestre registrado'}'),
                ),
              ],
            ),
          ),
          // Botón para cerrar sesión en la parte inferior
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ); // Redirige al login
              },
              tileColor: Colors.grey[200],
              textColor: Colors.black,
              iconColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
