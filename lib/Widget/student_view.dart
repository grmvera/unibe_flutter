import 'package:flutter/material.dart';
import 'qr_studen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentView extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool showAppBar;
  final bool showDetails;

  const StudentView({
    Key? key,
    required this.userData,
    this.showAppBar = true,
    this.showDetails = true,
  }) : super(key: key);

  @override
  _StudentViewState createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  bool isAccessRegistered = false;

  Future<void> _registerIngreso(BuildContext context) async {
    try {
      final String? userId =
          widget.userData['uid'];
      if (userId == null) {
        throw Exception('El identificador del usuario no está disponible.');
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        await docSnapshot.reference.update({'lastAccess': DateTime.now()});

        setState(() {
          isAccessRegistered = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso registrado exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error: No se encontró el usuario con UID $userId')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar ingreso: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? lastAccess =
        (widget.userData['lastAccess'] as Timestamp?)?.toDate();
    final bool isQrActive = _isQrAvailable(lastAccess);
    final int minutesRemaining =
        isQrActive ? 0 : _getMinutesUntilAvailable(lastAccess);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Carnet del Estudiante'),
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                ElevatedButton(
                  onPressed: isQrActive && !isAccessRegistered
                      ? () async => await _registerIngreso(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isAccessRegistered ? Colors.grey[300] : Colors.white,
                    foregroundColor:
                        isAccessRegistered ? Colors.grey[600] : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(
                    isAccessRegistered ? 'Esperando...' : 'Registrar Ingreso',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/carnet3.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isQrActive)
                  QrCodeWidget(
                    studentId: widget.userData['idNumber'],
                    qrColor: Colors.white,
                    size: 200.0,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'QR no disponible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (widget.showDetails) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${widget.userData['lastName']} ${widget.userData['firstName']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.userData['idNumber'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                if (!isQrActive)
                  Text(
                    'Acceso reciente: puedes volver a escanear en $minutesRemaining minutos.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isQrAvailable(DateTime? lastAccess) {
    if (lastAccess == null) return true;
    final DateTime now = DateTime.now();
    return now.difference(lastAccess).inMinutes >= 2;
  }

  int _getMinutesUntilAvailable(DateTime? lastAccess) {
    if (lastAccess == null) return 0;
    final DateTime now = DateTime.now();
    final int difference = 2 - now.difference(lastAccess).inMinutes;
    return difference > 0 ? difference : 0;
  }
}
