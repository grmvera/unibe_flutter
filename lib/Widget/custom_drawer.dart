import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unibe_app_control/login/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
              backgroundImage: _getProfileImage(userData),
              backgroundColor: Colors.grey[300],
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Este sistema es propiedad exclusiva de la Universidad UNIB.E y ha sido desarrollado para uso institucional. Implementado por Tabata Mendoza y Geovanny Vera, bajo los estándares técnicos y académicos establecidos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
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

  ImageProvider<Object> _getProfileImage(Map<String, dynamic> userData) {
    final profileImageUrl = userData['profileImage'];
    final selectedGender = userData['gender'];

    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return NetworkImage(profileImageUrl);
    } else if (selectedGender == 'Masculino') {

      return const NetworkImage(
        'https://firebasestorage.googleapis.com/v0/b/controlacceso-403b0.firebasestorage.app/o/default_images%2Fmasculino.png?alt=media&token=ba6cc3c1-615e-4d53-ac96-e35d94da6be7',
      );
    } else if (selectedGender == 'Femenino') {
      return const NetworkImage(
        'https://firebasestorage.googleapis.com/v0/b/controlacceso-403b0.firebasestorage.app/o/default_images%2Ffemenino.png?alt=media&token=d5955ec0-4847-44e8-99e1-bc340f0ab302',
      );
    } else {
      return const NetworkImage(
        'https://firebasestorage.googleapis.com/v0/b/controlacceso-403b0.firebasestorage.app/o/default_images%2Fpersona.png?alt=media&token=df204812-6c08-436d-ad65-ac0c21a50b61',
      );
    }
  }

  void _launchURL(BuildContext context) async {
    const url = 'https://acad.unibe.edu.ec/';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
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
