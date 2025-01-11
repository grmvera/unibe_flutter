import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart'; // Para usar kIsWeb
import 'dart:html' as html; // Solo para Flutter Web
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unibe_app_control/Widget/custom_app_bar.dart';
import 'package:unibe_app_control/Widget/custom_drawer.dart';
import 'package:unibe_app_control/Widget/custom_bottom_navigation_bar.dart';
import 'package:unibe_app_control/login/users_provider.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;

  // Variables para el ciclo y cuenta regresiva
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  Map<String, dynamic>? _cycleData;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchCycleData();
    _fetchProfileImage();
  }

  Future<void> _fetchCycleData() async {
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final String? cycleId = usuarioProvider.userData?['cycleId'];

    if (cycleId != null) {
      try {
        final DocumentSnapshot cycleSnapshot = await FirebaseFirestore.instance
            .collection('cycles')
            .doc(cycleId)
            .get();

        if (cycleSnapshot.exists) {
          final data = cycleSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _cycleData = data;
            final DateTime endDate = DateTime.parse(data['endDate']);
            _timeLeft = endDate.difference(DateTime.now());

            if (_timeLeft.isNegative) {
              _timeLeft = Duration.zero;
            }

            // Inicia el temporizador para actualizar cada segundo
            _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
              setState(() {
                if (_timeLeft.inSeconds > 0) {
                  _timeLeft = _timeLeft - const Duration(seconds: 1);
                } else {
                  _timer.cancel();
                }
              });
            });
          });
        }
      } catch (e) {
        print('Error al obtener el ciclo: $e');
      }
    }
  }

  Future<void> _fetchProfileImage() async {
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final String? imageUrl = usuarioProvider.userData?['profileImage'];
    if (imageUrl != null) {
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index != 2) {
      Navigator.pop(context); // Navega fuera de la pantalla de perfil
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final userData =
        usuarioProvider.userData ?? {}; // Proporciona un mapa vacío si es null

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        userName: userData['firstName'] ?? 'Usuario',
        userRole: userData['role'] ?? 'Sin Rol',
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: CustomDrawer(userData: userData),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  await _uploadProfileImage();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: _profileImageUrl == null
                      ? const Icon(Icons.camera_alt,
                          size: 30, color: Colors.white)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Nombre del usuario
            Text(
              '${userData['firstName'] ?? 'N/A'} ${userData['lastName'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              userData['email'] ?? 'Correo no disponible',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Tarjetas con la información del usuario
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.school, color: Colors.blue),
                title: const Text('Carrera'),
                subtitle: Text(userData['career'] ?? 'Sin carrera'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.badge, color: Colors.green),
                title: const Text('Rol'),
                subtitle: Text(userData['role'] ?? 'Sin rol'),
              ),
            ),
            // Mostrar ciclo solo si es estudiante
            if (userData['role'] == 'estudiante' && _cycleData != null)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.timer, color: Colors.purple),
                  title: Text('Ciclo: ${_cycleData!['name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Tiempo restante: ${_timeLeft.inDays} días, ${_timeLeft.inHours.remainder(24)} horas, ${_timeLeft.inMinutes.remainder(60)} minutos',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> _uploadProfileImage() async {
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final userId = usuarioProvider.userData?['uid'];

    if (userId == null) {
      print("Error: ID de usuario no encontrado.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado.')),
      );
      return;
    }

    try {
      if (kIsWeb) {
        final html.FileUploadInputElement uploadInput =
            html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.click();

        uploadInput.onChange.listen((event) async {
          final html.File? file = uploadInput.files?.first;
          if (file != null) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);

            reader.onLoad.listen((event) async {
              final Uint8List fileData = reader.result as Uint8List;
              final String storagePath = 'profile_images/$userId';
              final ref = FirebaseStorage.instance.ref(storagePath);
              final uploadTask = ref.putData(fileData);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return UploadProgressDialog(uploadTask: uploadTask);
                },
              );

              await uploadTask.whenComplete(() async {
                final String downloadUrl = await ref.getDownloadURL();
                print("URL obtenida: $downloadUrl");

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'profileImage': downloadUrl});

                setState(() {
                  _profileImageUrl = downloadUrl;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Imagen actualizada correctamente.')),
                );
              });
            });

            reader.onError.listen((error) {
              print('Error al leer el archivo: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al leer el archivo.')),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
            );
          }
        });
      } else {
        final picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          final io.File file = io.File(image.path);
          final String storagePath = 'profile_images/$userId';
          final ref = FirebaseStorage.instance.ref(storagePath);
          final uploadTask = ref.putFile(file);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return UploadProgressDialog(uploadTask: uploadTask);
            },
          );

          await uploadTask.whenComplete(() async {
            final String downloadUrl = await ref.getDownloadURL();
            print("URL obtenida: $downloadUrl");

            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'profileImage': downloadUrl});

            setState(() {
              _profileImageUrl = downloadUrl;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Imagen actualizada correctamente.')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error al subir la imagen: $e');
      print('Detalles del error: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al actualizar la imagen de perfil.')),
      );
    }
  }
}

class UploadProgressDialog extends StatefulWidget {
  final UploadTask uploadTask;

  const UploadProgressDialog({required this.uploadTask, Key? key})
      : super(key: key);

  @override
  _UploadProgressDialogState createState() => _UploadProgressDialogState();
}

class _UploadProgressDialogState extends State<UploadProgressDialog> {
  double _progress = 0.0;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _startMonitoringProgress();
  }

  void _startMonitoringProgress() {
    widget.uploadTask.snapshotEvents.listen(
      (snapshot) {
        if (_isCancelled) return;

        if (snapshot.state == TaskState.running) {
          setState(() {
            _progress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        } else if (snapshot.state == TaskState.success) {
          Navigator.of(context).pop(); // Cierra el diálogo al completar
        } else if (snapshot.state == TaskState.error) {
          Navigator.of(context).pop(); // Cierra el diálogo en caso de error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen.')),
          );
        }
      },
      onError: (error) {
        Navigator.of(context).pop(); // Asegura que el diálogo se cierra
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error durante la carga de la imagen.')),
        );
      },
    );
  }

  void _cancelUpload() {
    widget.uploadTask.cancel();
    setState(() {
      _isCancelled = true;
    });
    Navigator.of(context).pop(); // Cierra el diálogo al cancelar
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Subiendo imagen...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 16),
          Text('Progreso: ${(_progress * 100).toStringAsFixed(2)}%'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancelUpload,
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
