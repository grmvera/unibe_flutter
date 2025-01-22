import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
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

  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  Map<String, dynamic>? _cycleData;
  String? _profileImageUrl;
  String? _selectedGender;

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
    try {
      final usuarioProvider =
          Provider.of<UsuarioProvider>(context, listen: false);
      final String? userId = usuarioProvider.userData?['uid'];

      if (userId == null) {
        throw Exception("ID de usuario no encontrado.");
      }

      final documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();

        setState(() {
          _profileImageUrl = data?['profileImage']; // Imagen del usuario
          _selectedGender = data?['gender']; // Género del usuario
        });
      } else {
        print("El documento del usuario no existe.");
      }
    } catch (e) {
      print("Error al cargar la imagen o el género de perfil: $e");
    }
  }

  ImageProvider<Object> _getProfileImage() {
    // Imprime los valores actuales para depuración
    print('_profileImageUrl: $_profileImageUrl');
    print('_selectedGender: $_selectedGender');

    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      // Imagen personalizada del usuario
      return NetworkImage(_profileImageUrl!);
    } else if (_selectedGender == 'Masculino') {
      // Imagen predeterminada para género masculino
      return NetworkImage(
        'https://firebasestorage.googleapis.com/v0/b/controlacceso-403b0.firebasestorage.app/o/default_images%2Fmasculino.png?alt=media&token=ba6cc3c1-615e-4d53-ac96-e35d94da6be7',
      );
    } else if (_selectedGender == 'Femenino') {
      // Imagen predeterminada para género femenino
      return NetworkImage(
        'https://firebasestorage.googleapis.com/v0/b/controlacceso-403b0.firebasestorage.app/o/default_images%2Ffemenino.png?alt=media&token=d5955ec0-4847-44e8-99e1-bc340f0ab302',
      );
    } else {
      // Imagen predeterminada genérica
      return NetworkImage(
        'https://firebasestorage.googleapis.com/v0/b/controlacceso-403b0.firebasestorage.app/o/default_images%2Fpersona.png?alt=media&token=df204812-6c08-436d-ad65-ac0c21a50b61',
      );
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
      Navigator.pop(context);
    }
  }

  Future<void> _updateGender(String gender) async {
    try {
      final usuarioProvider =
          Provider.of<UsuarioProvider>(context, listen: false);
      final userId = usuarioProvider.userData?['uid'];

      if (userId == null) {
        throw Exception("ID de usuario no encontrado.");
      }

      final documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'gender': gender}, SetOptions(merge: true));
      } else {
        throw Exception("El documento del usuario no existe en Firestore.");
      }

      setState(() {
        _selectedGender = gender;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Género actualizado correctamente.')),
      );
    } catch (e) {
      print("Error al actualizar el género: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el género.')),
      );
    }
  }

  Future<void> _uploadProfileImage() async {
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final userId = usuarioProvider.userData?['uid'];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado.')),
      );
      return;
    }

    try {
      Uint8List? fileBytes;
      String fileName = "profile_images/$userId.png";

      if (kIsWeb) {
        // Selección de archivos en la web
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
          );
          return;
        }

        fileBytes = result.files.first.bytes; // Obtiene los bytes del archivo
      } else {
        // Selección de imágenes en dispositivos móviles
        final picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
          );
          return;
        }

        final file = io.File(image.path);
        if (!file.existsSync()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: El archivo no existe.')),
          );
          return;
        }

        fileBytes = await file.readAsBytes(); // Lee los bytes del archivo
      }

      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al leer el archivo.')),
        );
        return;
      }

      final ref = FirebaseStorage.instance.ref(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subiendo imagen, por favor espera...')),
      );

      // Subir archivo a Firebase Storage
      final uploadTask = ref.putData(fileBytes);

      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.state == TaskState.running) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print("Progreso de subida: $progress%");
        }
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profileImage': downloadUrl});

      setState(() {
        _profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen actualizada correctamente.')),
      );
    } catch (e) {
      print('Error al subir la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la imagen de perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final userData = usuarioProvider.userData ?? {};

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
            GestureDetector(
              onTap: () async {
                await _uploadProfileImage();
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _getProfileImage(),
                backgroundColor: Colors.blue[100],
                child: _profileImageUrl == null
                    ? const Icon(Icons.camera_alt,
                        size: 30, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
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
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.pink),
                title: const Text('Género'),
                subtitle: DropdownButton<String>(
                  value: _selectedGender,
                  onChanged: (value) {
                    if (value != null) {
                      _updateGender(value); // Actualiza el género en Firestore
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'Masculino',
                      child: Text('Masculino'),
                    ),
                    DropdownMenuItem(
                      value: 'Femenino',
                      child: Text('Femenino'),
                    ),
                  ],
                ),
              ),
            ),
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
        userRole: usuarioProvider.userData!['role'],
      ),
    );
  }
}
