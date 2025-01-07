import 'package:flutter/material.dart';
import 'qr_studen.dart';

class StudentView extends StatelessWidget {
  final Map<String, dynamic> userData;

  const StudentView({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carnet del Estudiante')),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrCodeWidget(
            studentEmail: userData['email'],
            studentId: userData['idNumber'],
            studentName: userData['firstName'],
          ),
          const SizedBox(height: 20),
          Text(
            '${userData['lastName']} ${userData['firstName']}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            userData['idNumber'],
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            userData['career'],
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            userData['semestre'],
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
