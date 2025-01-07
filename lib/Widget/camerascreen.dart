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
  String? statusMessage; // Mensaje para mostrar el estado al usuario

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
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: isCameraInitialized ? _buildQRScanner() : const Center(child: CircularProgressIndicator()),
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

  Widget _buildQRScanner() {
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;

    // Escucha el flujo de datos del escaneo
    _qrController!.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        setState(() {
          statusMessage = 'Código QR detectado: ${scanData.code}';
        });
        print('Código QR detectado: ${scanData.code}');
        await _processQRCode(scanData.code!);
        _qrController?.pauseCamera(); // Pausa para evitar múltiples lecturas
      } else {
        setState(() {
          statusMessage = 'No se detectó ningún código QR.';
        });
        print('No se detectó ningún código QR');
      }
    });
  }

  Future<void> _processQRCode(String qrData) async {
    try {
      Map<String, dynamic> data = {};
      try {
        data = json.decode(qrData); // Intenta decodificar como JSON
      } catch (e) {
        data['id'] = qrData; // Si falla, trata el QR como ID directo
      }

      if (data.containsKey('id')) {
        final studentData = await fetchStudentFromFirebase(data['id']);
        if (studentData != null) {
          setState(() {
            statusMessage = null; // Limpia el mensaje antes de navegar
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentView(userData: studentData),
            ),
          ).then((_) {
            _qrController?.resumeCamera(); // Reactiva la cámara al regresar
          });
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
        return querySnapshot.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error al buscar en Firebase: $e';
      });
      return null;
    }
  }
}
