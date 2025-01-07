import 'dart:convert'; // Para decodificar JSON
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Para escaneo en Web y Android
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase
import 'student_view.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  QRViewController? _qrController; // Controlador para Web y Android
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isCameraInitialized = true;
    });
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
      body: isCameraInitialized ? _buildQRScanner() : const Center(child: CircularProgressIndicator()),
    );
  }

  // Construcción del escáner QR para Web y Android
  Widget _buildQRScanner() {
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  // Lógica de creación del QRView
  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;

    _qrController!.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        _processQRCode(scanData.code!);
        _qrController?.pauseCamera(); // Pausa para evitar múltiples escaneos
      }
    });
  }

  // Procesar el QR escaneado
  void _processQRCode(String qrData) async {
    try {
      // Decodifica el QR como JSON o texto
      Map<String, dynamic> data = {};
      try {
        data = json.decode(qrData);
      } catch (e) {
        // Si no es JSON válido, asume que el QR contiene un ID directamente
        data['id'] = qrData;
      }

      // Busca el ID en Firebase
      if (data.containsKey('id')) {
        final studentData = await fetchStudentFromFirebase(data['id']);
        if (studentData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentView(userData: studentData),
            ),
          ).then((_) {
            _qrController?.resumeCamera(); // Reactiva la cámara al regresar
          });
        } else {
          _showError('Estudiante con ID ${data['id']} no encontrado.');
        }
      } else {
        _showError('El QR no contiene un ID válido.');
      }
    } catch (e) {
      _showError('Error al procesar el QR: $e');
    }
  }

  // Buscar estudiante en Firebase
  Future<Map<String, dynamic>?> fetchStudentFromFirebase(String idNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('idNumber', isEqualTo: idNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      _showError('Error al buscar estudiante en Firebase: $e');
      return null;
    }
  }

  // Mostrar errores con SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _qrController?.resumeCamera(); // Reactiva la cámara tras el error
  }
}
