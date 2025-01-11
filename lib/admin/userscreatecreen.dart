import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widget/custom_app_bar.dart';
import '../Widget/custom_drawer.dart';
import '../Widget/custom_bottom_navigation_bar.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class UserCreationScreen extends StatefulWidget {
  const UserCreationScreen({Key? key}) : super(key: key);

  @override
  State<UserCreationScreen> createState() => _UserCreationScreenState();
}

class _UserCreationScreenState extends State<UserCreationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  String? _selectedProfile;
  String? _selectedCycle;
  String? _selectedCareer;
  bool _isLoading = false;
  List<DocumentSnapshot> _cycles = [];
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchCycles();
  }

  Future<void> _fetchCycles() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cycles')
          .where('isActive', isEqualTo: true)
          .get();
      setState(() {
        _cycles = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los ciclos: $e')),
      );
    }
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProfile == 'Estudiante' &&
        (_selectedCycle == null || _selectedCareer == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecciona un período y una carrera')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String idNumber = _idNumberController.text.trim();
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String email = _emailController.text.trim();
      String role =
          _selectedProfile == 'Administrador' ? 'admin' : 'estudiante';
      final usuarioProvider =
          Provider.of<UsuarioProvider>(context, listen: false);

      // Crear el usuario en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: idNumber);

      User? user = userCredential.user;

      if (user != null) {
        // Guardar los datos en Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'idNumber': idNumber,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'role': role,
          'status': true,
          'isFirstLogin': true,
          'created': usuarioProvider.userData!['firstName'].toString(),
          'isDeleted': false,
          'profileImage': '',
          if (role == 'estudiante') 'cycleId': _selectedCycle,
          if (role == 'estudiante') 'career': _selectedCareer,
          if (role == 'estudiante') 'semestre': _semesterController.text.trim(),
          if (role == 'estudiante')
            'lastAccess': null, // Inicializar lastAccess
        });

        // Llamar a la Firebase Function para enviar el correo
        final url = Uri.parse(
            "https://sendemailonusercreation-vmgeqj7yha-uc.a.run.app");

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'displayName': "$firstName $lastName",
            'idNumber': idNumber,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario creado y correo enviado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Usuario creado, pero error al enviar correo')),
          );
        }

        _formKey.currentState!.reset();
        _idNumberController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _semesterController.clear();
        setState(() {
          _selectedProfile = null;
          _selectedCycle = null;
          _selectedCareer = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        userName: usuarioProvider.userData!['firstName'] ?? 'Usuario',
        userRole: usuarioProvider.userData!['role'] ?? 'Sin Rol',
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: CustomDrawer(userData: usuarioProvider.userData ?? {}),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear Usuario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedProfile,
                  items: ['Administrador', 'Estudiante'].map((profile) {
                    return DropdownMenuItem<String>(
                      value: profile,
                      child: Text(profile),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Perfil',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedProfile = value;
                      if (value == 'Administrador') {
                        _selectedCycle = null;
                        _selectedCareer = null;
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecciona un perfil';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _idNumberController,
                  decoration: InputDecoration(
                    labelText: 'Cédula',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa una cédula';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombres',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa los nombres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa los apellidos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un correo electrónico';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                if (_selectedProfile == 'Estudiante')
                  TextFormField(
                    controller: _semesterController,
                    decoration: InputDecoration(
                      labelText: 'Semestre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (_selectedProfile == 'Estudiante' &&
                          (value == null || value.isEmpty)) {
                        return 'Por favor, ingresa el semestre';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),
                if (_selectedProfile == 'Estudiante')
                  DropdownButtonFormField<String>(
                    value: _selectedCareer,
                    items: ['Ingeniería de Software', 'Medicina', 'Derecho']
                        .map((career) {
                      return DropdownMenuItem<String>(
                        value: career,
                        child: Text(career),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Carrera',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedCareer = value;
                      });
                    },
                    validator: (value) {
                      if (_selectedProfile == 'Estudiante' && value == null) {
                        return 'Por favor, selecciona una carrera';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),
                if (_selectedProfile == 'Estudiante')
                  DropdownButtonFormField<String>(
                    value: _selectedCycle,
                    items: _cycles.map((cycle) {
                      return DropdownMenuItem<String>(
                        value: cycle.id,
                        child: Text(cycle['name']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedCycle = value;
                      });
                    },
                    validator: (value) {
                      if (_selectedProfile == 'Estudiante' && value == null) {
                        return 'Por favor, selecciona un período';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1225F5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Creando...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Crear Usuario',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
