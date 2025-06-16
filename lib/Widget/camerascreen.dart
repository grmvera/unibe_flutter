import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_view.dart';

// ...existing code...

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Elimina todo lo relacionado con QRViewController y QRView
  bool isCameraInitialized = false;
  bool isProcessing = false;
  String? statusMessage;

  @override
  void initState() {
    super.initState();
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Código')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: isCameraInitialized
                ? const Center(
                    child: Text(
                      'Funcionalidad de escaneo QR no implementada.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          if (statusMessage != null)
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  statusMessage!,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Puedes dejar los métodos de procesamiento si los necesitas para el futuro,
  // pero actualmente no se usan porque no hay escaneo QR.
  Future<void> _processQRCode(String qrData) async {
    try {
      Map<String, dynamic> data = {};
      try {
        data = json.decode(qrData);
      } catch (e) {
        data['id'] = qrData;
      }

      if (data.containsKey('id')) {
        final studentData = await fetchStudentFromFirebase(data['id']);
        if (studentData != null) {
          setState(() {
            statusMessage = null;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentView(
                userData: studentData,
                showAppBar: true,
              ),
            ),
          );
        } else {
          setState(() {
            statusMessage = 'Estudiante con ID ${data['id']} no encontrado.';
          });
        }
      } else {
        setState(() {
          statusMessage = 'El QR no contiene un ID válido.';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error al procesar el QR: $e';
      });
    }
  }

  Future<Map<String, dynamic>?> fetchStudentFromFirebase(String idNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('idNumber', isEqualTo: idNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        userData['docId'] = querySnapshot.docs.first.id;
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
// ...existing code...