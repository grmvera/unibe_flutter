import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeWidget extends StatelessWidget {
  final String studentId; // Solo incluiremos el ID del estudiante
  final Color qrColor; // Color del QR
  final double size; // Tamaño del QR

  const QrCodeWidget({
    Key? key,
    required this.studentId,
    this.qrColor = Colors.black, // Color por defecto
    this.size = 100.0, // Tamaño por defecto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: studentId, // Solo el ID del estudiante
      version: QrVersions.auto,
      size: size, // Tamaño dinámico
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: qrColor, // Color de los ojos del QR
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: qrColor, // Color de los módulos del QR
      ),
    );
  }
}
