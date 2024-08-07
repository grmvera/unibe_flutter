import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert'; 
class QrCodeWidget extends StatelessWidget {
  final String? studentName;
  final String? studentId;
  final String? studentEmail;
  const QrCodeWidget({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.studentEmail,
  });
  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({ 
      'nombre': studentName,
      'id': studentId,
      'correo': studentEmail
    });
    return Center(
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: 300.0,
      ),
    );
  }
}