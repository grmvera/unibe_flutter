import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeWidget extends StatelessWidget {
  final String studentId; 
  final Color qrColor;
  final double size; 

  const QrCodeWidget({
    Key? key,
    required this.studentId,
    this.qrColor = Colors.black, 
    this.size = 100.0, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: studentId,
      version: QrVersions.auto,
      size: size, // Tamaño dinámico
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: qrColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: qrColor, 
      ),
    );
  }
}
