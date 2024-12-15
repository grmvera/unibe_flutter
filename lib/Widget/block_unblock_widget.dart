import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';

class BlockUnblockStudentsWidget {
  static Future<void> showBlockUnblockDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo haciendo clic afuera
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              const Icon(Icons.manage_accounts, color: Colors.blueAccent, size: 30),
              const SizedBox(width: 10),
              const Text(
                'Gestión de Estudiantes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                '¿Qué acción deseas realizar?\nSelecciona un archivo Excel con los números de cédula para bloquear o desbloquear estudiantes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // Centra los botones
          actions: [
            _buildStyledButton(
              context,
              'Bloquear',
              Colors.red,
              Colors.white,
              () async {
                await _pickExcel(context, true);
              },
            ),
            _buildStyledButton(
              context,
              'Desbloquear',
              Colors.green,
              Colors.white,
              () async {
                await _pickExcel(context, false);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildStyledButton(BuildContext context, String label, Color bgColor, Color fgColor, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Seleccionar archivo Excel
  static Future<void> _pickExcel(BuildContext context, bool isBlocking) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      Uint8List bytes = result.files.single.bytes!;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            title: Text('Cargando...'),
            content: SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      );

      try {
        await _processExcel(bytes, isBlocking);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBlocking
                  ? 'Estudiantes bloqueados exitosamente.'
                  : 'Estudiantes desbloqueados exitosamente.',
            ),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el archivo: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ningún archivo.')),
      );
    }
  }

  // Procesar Excel
  static Future<void> _processExcel(Uint8List bytes, bool isBlocking) async {
    var excel = Excel.decodeBytes(bytes);
    List<String> idNumbers = [];

    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]!.rows;

      if (rows.isNotEmpty) {
        int? cedulaColumnIndex;
        for (int i = 0; i < rows[0].length; i++) {
          if (rows[0][i]?.value.toString().toLowerCase() == 'cedula') {
            cedulaColumnIndex = i;
            break;
          }
        }

        if (cedulaColumnIndex == null) {
          throw Exception('No se encontró la columna "cedula" en el archivo Excel.');
        }

        for (int i = 1; i < rows.length; i++) {
          var cellValue = rows[i][cedulaColumnIndex]?.value;
          if (cellValue != null) {
            idNumbers.add(cellValue.toString());
          }
        }
      }
    }

    for (String id in idNumbers) {
      await FirebaseFirestore.instance
          .collection('users')
          .where('idNumber', isEqualTo: id)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'status': isBlocking ? false : true});
        }
      });
    }
  }
}
