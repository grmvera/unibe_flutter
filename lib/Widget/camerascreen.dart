import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_view.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;
  bool isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    requestCameraPermission().then((isGranted) {
      if (isGranted) {
        setState(() {
          isCameraPermissionGranted = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Se necesita acceso a la cámara para continuar.')),
        );
      }
    });
  }

  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    return status.isGranted;
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Código')),
      body: isCameraPermissionGranted
          ? QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;

    _qrController!.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        try {
          // Decodifica el JSON del QR
          final qrData = json.decode(scanData.code!);

          // Verifica si el JSON contiene el campo `id`
          if (qrData.containsKey('id')) {
            final String idNumber = qrData['id'];

            // Pausa la cámara para evitar múltiples lecturas
            _qrController?.pauseCamera();

            // Busca los datos del estudiante en Firebase
            final studentData = await fetchStudentFromFirebase(idNumber);

            if (studentData != null) {
              // Navega hacia la pantalla de carnet con los datos del estudiante
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentView(userData: studentData),
                ),
              ).then((_) {
                // Reactiva la cámara al regresar
                _qrController?.resumeCamera();
              });
            } else {
              // Muestra un mensaje si no se encuentra el estudiante
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Estudiante con ID $idNumber no encontrado.')),
              );
              _qrController
                  ?.resumeCamera(); // Reactiva la cámara si no se encuentra el estudiante
            }
          } else {
            // Muestra un error si el JSON no contiene el campo `id`
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El QR no contiene un ID válido.')),
            );
          }
        } catch (e) {
          // Maneja errores si el QR no es un JSON válido
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al leer el QR: $e')),
          );
        }
      }
    });
  }

  // Función para obtener datos del estudiante desde Firebase
  Future<Map<String, dynamic>?> fetchStudentFromFirebase(
      String idNumber) async {
    try {
      // Obtén la referencia a la colección "users"
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('idNumber', isEqualTo: idNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Retorna el primer documento encontrado
        return querySnapshot.docs.first.data();
      } else {
        return null; // No se encontró el estudiante
      }
    } catch (e) {
      print('Error al buscar estudiante: $e');
      return null;
    }
  }
}
