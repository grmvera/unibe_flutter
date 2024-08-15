import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login/login_screen.dart';
import '../admin/admin_home_screen.dart';
import 'package:provider/provider.dart';
import '../login/users_provider.dart';
import '../login/change_password.dart';
import '../Widget/qr_studen.dart';
import '../Widget/botton_navigaton_bart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        // Si se selecciona la segunda pestaña
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      }
    });
  }

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
      body: IndexedStack(
        // Aquí se añade el IndexedStack
        index: _selectedIndex,
        children: [
          Center(
            // Contenido de la primera pestaña (index 0)
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
                      Text(
                          'Apellido: ${usuarioProvider.userData!['lastName']}'),
                      Text('Rol: ${usuarioProvider.userData!['role']}'),
                      if (usuarioProvider.userData!['role'] == 'student')
                        QrCodeWidget(
                            studentEmail: usuarioProvider.userData!['email'],
                            studentId: usuarioProvider.userData!['idNumber'],
                            studentName:
                                usuarioProvider.userData!['firstName']),
                      const SizedBox(height: 20),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
          Container(),
        ],
      ),
      bottomNavigationBar: const BottonNavigatonBart(),
    );
  }
}
