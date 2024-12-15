import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unibe_app_control/Widget/student_view.dart';
import '../Widget/custom_app_bar.dart';
import '../Widget/custom_bottom_navigation_bar.dart';
import '../Widget/custom_drawer.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';

class UpdateUserScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UpdateUserScreen({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController idNumberController;
  late TextEditingController emailController;
  int _selectedIndex = 0;
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: widget.userData['firstName'] ?? '');
    lastNameController =
        TextEditingController(text: widget.userData['lastName'] ?? '');
    idNumberController =
        TextEditingController(text: widget.userData['idNumber'] ?? '');
    emailController =
        TextEditingController(text: widget.userData['email'] ?? '');
    isBlocked = widget.userData['status'] == false;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    idNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> bloquearUsuario(String userId) async {
    final shouldBlock = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Bloqueo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Está seguro de bloquear al usuario ${firstNameController.text} ${lastNameController.text}?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    if (shouldBlock == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'status': false,
          'information_output': DateTime.now(),
        });
        setState(() {
          isBlocked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario bloqueado exitosamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al bloquear el usuario: $e')),
        );
      }
    }
  }

  Future<void> desbloquearUsuario(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'status': true,
        'information_output': '',
      });
      setState(() {
        isBlocked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario desbloqueado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al desbloquear el usuario: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final isStudent = widget.userData['role'] == 'estudiante';

    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        userName: usuarioProvider.userData!['firstName'] ?? 'Usuario',
        userRole: usuarioProvider.userData!['role'] ?? 'Sin Rol',
        scaffoldKey: scaffoldKey,
      ),
      endDrawer: CustomDrawer(userData: usuarioProvider.userData!),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Actualizar Usuario',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isBlocked ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isBlocked ? 'Bloqueado' : 'Activo',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: idNumberController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Cédula',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isStudent)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        bloquearUsuario(widget.userId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Bloquear'),
                    ),
                    if (isBlocked)
                      ElevatedButton(
                        onPressed: () {
                          desbloquearUsuario(widget.userId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Desbloquear'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text('Carnet del Estudiante'),
                              ),
                              body: Center(
                                child: StudentView(userData: widget.userData),
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Ver Carnet'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userId)
                          .update({
                        'firstName': firstNameController.text,
                        'lastName': lastNameController.text,
                        'email': emailController.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Usuario actualizado exitosamente')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error al actualizar el usuario')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
