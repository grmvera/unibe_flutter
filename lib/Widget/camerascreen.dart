import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'student_view.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  QRViewController? _qrController; 
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool isCameraInitialized = false;
  bool isProcessing = false; // Bandera para control de procesamiento único
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
            child: isCameraInitialized
                ? _buildQRScanner()
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

  Widget _buildQRScanner() {
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;

    _qrController!.scannedDataStream.listen((scanData) async {
      if (!isProcessing && scanData.code != null && scanData.code!.isNotEmpty) {
        isProcessing = true; // Marca como en procesamiento
        setState(() {
          statusMessage = 'Código QR detectado: ${scanData.code}';
        });
        print('Código QR detectado: ${scanData.code}');
        await _processQRCode(scanData.code!);
        _qrController?.pauseCamera(); 
        isProcessing = false; // Libera la bandera después de completar el procesamiento
      } else if (!isProcessing) {
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
          ).then((_) {
            _qrController?.resumeCamera(); 
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
        final userData = querySnapshot.docs.first.data();
        userData['docId'] = querySnapshot.docs.first.id;

        print('Usuario encontrado: ${userData['idNumber']}');
        return userData;
      } else {
        print('No se encontró ningún usuario con el ID: $idNumber');
        return null;
      }
    } catch (e) {
      print('Error al buscar en Firebase: $e');
      return null;
    }
  }
}
