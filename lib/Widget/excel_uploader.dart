import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ExcelUploader extends StatefulWidget {
  const ExcelUploader({super.key});

  @override
  State<ExcelUploader> createState() => _ExcelUploaderState();
}

class _ExcelUploaderState extends State<ExcelUploader> {
  String? selectedCycle;
  List<DocumentSnapshot> cycles = [];

  @override
  void initState() {
    super.initState();
    _fetchCycles();
  }

  Future<void> _fetchCycles() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('cycles').get();
      setState(() {
        cycles = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los ciclos: $e')),
      );
    }
  }

  Future<void> _uploadExcel(BuildContext context) async {
    if (selectedCycle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un ciclo primero')),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.isNotEmpty) {
        var bytes = result.files.single.bytes;

        if (bytes != null) {
          var excel = Excel.decodeBytes(bytes);
          String fileName = result.files.single.name;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Subiendo Archivo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Procesando archivo: $fileName'),
                  const SizedBox(height: 16),
                  const Text(
                    'Creando usuarios, por favor espera...',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );

          List<Map<String, String>> usersToUpdate = [];
          bool errorOccurred = false;

          for (var table in excel.tables.keys) {
            List<List<Data?>> rows = excel.tables[table]!.rows;

            for (var row in rows.skip(1)) {
              try {
                var idNumber = row[0]?.value?.toString();
                var firstName = row[1]?.value?.toString();
                var lastName = row[2]?.value?.toString();
                var email = row[3]?.value?.toString();
                var career = row[4]?.value?.toString();
                var semestre = row[5]?.value?.toString();
                var password = idNumber;

                if (idNumber != null &&
                    firstName != null &&
                    lastName != null &&
                    email != null &&
                    career != null &&
                    semestre != null) {
                  // Buscar usuario existente por idNumber
                  var existingUsers = await FirebaseFirestore.instance
                      .collection('users')
                      .where('idNumber', isEqualTo: idNumber)
                      .get();

                  if (existingUsers.docs.isNotEmpty) {
                    // Usuario ya existe, actualizar datos
                    var userDoc = existingUsers.docs.first;

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userDoc.id)
                        .update({
                      'firstName': firstName,
                      'lastName': lastName,
                      'email': email,
                      'career': career,
                      'semestre': semestre,
                      'cycleId': selectedCycle,
                      'status': true,
                      'updated_at': DateTime.now(),
                    });

                    //enlista a los usuarios existentes
                    if (userDoc['email'] != email) {
                      usersToUpdate.add({
                        'uid': userDoc.id,
                        'newEmail': email,
                      });
                    }
                  } else {
                    // crear usuarios nuevos
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: email,
                      password: password!,
                    );

                    User? user = userCredential.user;

                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                        'idNumber': idNumber,
                        'firstName': firstName,
                        'lastName': lastName,
                        'email': email,
                        'career': career,
                        'role': 'estudiante',
                        'semestre': semestre,
                        'cycleId': selectedCycle,
                        'information_input': DateTime.now(),
                        'isFirstLogin': true,
                        'status': true,
                      });
                    }
                  }
                } else {
                  throw Exception('Datos incompletos en la fila: $row');
                }
              } catch (e) {
                errorOccurred = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al procesar fila: $e')),
                );
              }
            }
          }

          if (usersToUpdate.isNotEmpty) {
            try {
              await _updateEmailsInBulk(usersToUpdate);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Correos actualizados en Firebase Auth')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error en actualización masiva: $e')),
              );
            }
          }

          Navigator.pop(context);

          if (!errorOccurred) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Usuarios creados con éxito')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Archivo vacío o no válido')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se seleccionó ningún archivo')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el archivo: $e')),
      );
    }
  }

  Future<void> _updateEmailsInBulk(
      List<Map<String, String>> usersToUpdate) async {
    final uri = Uri.parse('https://updateemailsinbulk-vmgeqj7yha-uc.a.run.app');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'users': usersToUpdate}),
      );
        print(jsonEncode({'users': usersToUpdate}));

      if (response.statusCode != 200) {
        throw Exception(
            'Error en la respuesta de la función: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al actualizar correos en Auth: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Seleccionar Ciclo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedCycle,
          items: cycles.map((cycle) {
            return DropdownMenuItem<String>(
              value: cycle.id,
              child: Text(
                cycle['name'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1225F5), width: 2),
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedCycle = value;
            });
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: selectedCycle == null
                ? null
                : () {
                    _uploadExcel(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedCycle == null
                  ? Colors.grey
                  : const Color.fromARGB(255, 46, 62, 235),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 24,
              ),
              elevation: 6,
              shadowColor: Colors.black45,
            ),
            icon: const Icon(
              Icons.upload_file,
              size: 24,
              color: Colors.white,
            ),
            label: const Text(
              'Cargar Archivo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
