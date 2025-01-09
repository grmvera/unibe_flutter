import 'package:flutter/material.dart';
import 'qr_studen.dart'; // Widget para generar el QR.
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore.

class StudentView extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool showAppBar; // Control del AppBar.
  final bool showDetails; // Control para mostrar detalles (nombre y cédula).

  const StudentView({
    Key? key,
    required this.userData,
    this.showAppBar = true,
    this.showDetails = true, // Por defecto muestra detalles.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener tiempo restante en minutos.
    final DateTime? lastAccess = (userData['lastAccess'] as Timestamp?)?.toDate();
    final bool isQrActive = _isQrAvailable(lastAccess);
    final int minutesRemaining = isQrActive ? 0 : _getMinutesUntilAvailable(lastAccess);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              title: const Text('Carnet del Estudiante'),
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                if (isQrActive)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _registerIngreso(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al registrar ingreso: $e'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Registrar Ingreso',
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: null, // Deshabilitado cuando QR no está disponible.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Esperando...',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/carnet3.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isQrActive)
                  QrCodeWidget(
                    studentId: userData['idNumber'],
                    qrColor: Colors.white,
                    size: 200.0,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'QR no disponible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (showDetails) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${userData['lastName']} ${userData['firstName']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    userData['idNumber'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                if (!isQrActive)
                  Text(
                    'Acceso reciente: puedes volver a escanear en $minutesRemaining minutos.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isQrAvailable(DateTime? lastAccess) {
    if (lastAccess == null) return true;
    final DateTime now = DateTime.now();
    return now.difference(lastAccess).inMinutes >= 120;
  }

  int _getMinutesUntilAvailable(DateTime? lastAccess) {
    if (lastAccess == null) return 0;
    final DateTime now = DateTime.now();
    final int difference = 120 - now.difference(lastAccess).inMinutes;
    return difference > 0 ? difference : 0;
  }

  Future<void> _registerIngreso(BuildContext context) async {
    try {
      final userId = userData['idNumber'];
      if (userId == null) {
        throw Exception('El identificador del usuario no está disponible.');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'lastAccess': DateTime.now()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingreso registrado exitosamente')),
      );
    } catch (e) {
      throw Exception('Error al registrar ingreso: $e');
    }
  }
}
