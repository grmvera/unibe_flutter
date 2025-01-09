import 'package:flutter/material.dart';
import 'qr_studen.dart';

class StudentView extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool showAppBar; // Control del AppBar
  final bool showDetails; // Control para mostrar detalles (nombre y cédula)

  const StudentView({
    Key? key,
    required this.userData,
    this.showAppBar = true,
    this.showDetails = true, // Por defecto muestra detalles
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                QrCodeWidget(
                  studentId: userData['idNumber'],
                  qrColor: Colors.white,
                  size: 200.0,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
