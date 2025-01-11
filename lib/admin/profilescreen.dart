import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unibe_app_control/Widget/custom_app_bar.dart';
import 'package:unibe_app_control/Widget/custom_drawer.dart';
import 'package:unibe_app_control/Widget/custom_bottom_navigation_bar.dart';
import 'package:unibe_app_control/login/users_provider.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;

  // Variables para el ciclo y cuenta regresiva
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  Map<String, dynamic>? _cycleData;

  @override
  void initState() {
    super.initState();
    _fetchCycleData();
  }

  Future<void> _fetchCycleData() async {
    final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
    final String? cycleId = usuarioProvider.userData?['cycleId'];

    if (cycleId != null) {
      try {
        final DocumentSnapshot cycleSnapshot =
            await FirebaseFirestore.instance.collection('cycles').doc(cycleId).get();

        if (cycleSnapshot.exists) {
          final data = cycleSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _cycleData = data;
            final DateTime endDate = DateTime.parse(data['endDate']);
            _timeLeft = endDate.difference(DateTime.now());

            if (_timeLeft.isNegative) {
              _timeLeft = Duration.zero;
            }

            // Inicia el temporizador para actualizar cada segundo
            _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
              setState(() {
                if (_timeLeft.inSeconds > 0) {
                  _timeLeft = _timeLeft - const Duration(seconds: 1);
                } else {
                  _timer.cancel();
                }
              });
            });
          });
        }
      } catch (e) {
        print('Error al obtener el ciclo: $e');
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index != 2) {
      Navigator.pop(context); // Navega fuera de la pantalla de perfil
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final userData = usuarioProvider.userData ?? {}; // Proporciona un mapa vacío si es null

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        userName: userData['firstName'] ?? 'Usuario',
        userRole: userData['role'] ?? 'Sin Rol',
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: CustomDrawer(userData: userData),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: const AssetImage('assets/profile_picture.png'), // Cambiar por una imagen válida
                backgroundColor: Colors.blue[100],
              ),
            ),
            const SizedBox(height: 16),
            // Nombre del usuario
            Text(
              '${userData['firstName'] ?? 'N/A'} ${userData['lastName'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              userData['email'] ?? 'Correo no disponible',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Tarjetas con la información del usuario
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.school, color: Colors.blue),
                title: const Text('Carrera'),
                subtitle: Text(userData['career'] ?? 'Sin carrera'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.badge, color: Colors.green),
                title: const Text('Rol'),
                subtitle: Text(userData['role'] ?? 'Sin rol'),
              ),
            ),
            // Mostrar ciclo solo si es estudiante
            if (userData['role'] == 'estudiante' && _cycleData != null)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.timer, color: Colors.purple),
                  title: Text('Ciclo: ${_cycleData!['name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Tiempo restante: ${_timeLeft.inDays} días, ${_timeLeft.inHours.remainder(24)} horas, ${_timeLeft.inMinutes.remainder(60)} minutos',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
