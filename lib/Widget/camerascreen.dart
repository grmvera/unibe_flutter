import 'dart:convert'; // Para decodificar JSON
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Para Web
import 'package:camera/camera.dart'; // Para Móviles
import 'student_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Controladores para móvil y web
  CameraController? _cameraController; // Para móvil
  QRViewController? _qrController; // Para web
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // En la Web no es necesario inicializar la cámara manualmente
      setState(() {
        isCameraInitialized = true;
      });
    } else {
      // Inicialización para móviles
      initializeMobileCamera();
    }
  }

  Future<void> initializeMobileCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      _qrController?.dispose();
    } else {
      _cameraController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Código')),
      body: kIsWeb ? _buildWebScanner() : _buildMobileScanner(),
    );
  }

  // Construir para Web
  Widget _buildWebScanner() {
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreatedWeb,
    );
  }

  // Construir para Móviles
  Widget _buildMobileScanner() {
    return isCameraInitialized
        ? CameraPreview(_cameraController!)
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  // Lógica para la Web
  void _onQRViewCreatedWeb(QRViewController controller) {
    _qrController = controller;
    _qrController!.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        _processQRCode(scanData.code!);
      }
    });
  }

  // Lógica para Móviles
  void _onQRViewCreatedMobile(String scanData) {
    _processQRCode(scanData);
  }

  // Lógica Común para Procesar el QR
  void _processQRCode(String qrData) async {
    try {
      final data = json.decode(qrData);
      if (data.containsKey('id')) {
        final studentData = await fetchStudentFromFirebase(data['id']);
        if (studentData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentView(userData: studentData),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Estudiante con ID ${data['id']} no encontrado.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El QR no contiene un ID válido.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el QR: $e')),
      );
    }
  }

  // Función para Buscar en Firebase
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
      print('Error al buscar estudiante en Firebase: $e');
      return null;
    }
  }
}
