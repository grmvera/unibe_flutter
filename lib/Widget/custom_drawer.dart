import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unibe_app_control/login/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;

  const CustomDrawer({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                size: 50,
                color: Colors.black,
              ),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1225F5),
              gradient: LinearGradient(
                colors: [Color(0xFF1225F5), Color(0xFF4A8DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.open_in_browser, color: Colors.indigo),
                  title: const Text(
                    'Académico UNIBE',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () => _launchURL(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              tileColor: Colors.grey[200],
              textColor: Colors.black,
              iconColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(BuildContext context) async {
    const url = 'https://flutter.dev';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode
                .externalApplication);
      } else {
        throw 'No se pudo abrir la URL';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir la URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
