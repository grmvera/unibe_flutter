import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserTable extends StatefulWidget {
  const UserTable({Key? key}) : super(key: key);

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('status', isEqualTo: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: SizedBox(
            // Agrega un SizedBox con un alto fijo
            height: 300, // Ajusta el alto según tus necesidades
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Cedula')),
                DataColumn(label: Text('Correo')),
                DataColumn(label: Text('Aciones')),
              ],
              rows: snapshot.data!.docs
                  .map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return DataRow(
                      cells: [
                        DataCell(Text(data['firstName'] ?? '')),
                        DataCell(Text(data['idNumber'] ?? '')),
                        DataCell(Text(data['email'] ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.disabled_by_default),
                                onPressed: () {
                                  _deleteUser(document.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  _showUpdateUserDialog(context, document);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  })
                  .take(5)
                  .toList(), // Limita la vista a 5 filas
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'status': false});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario desactivado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al desactivar el usuario:')),
      );
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showUpdateUserDialog(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    // Controladores para los campos del formulario
    final firstNameController =
        TextEditingController(text: data['firstName'] ?? '');
    final emailController = TextEditingController(text: data['email'] ?? '');
    final lastNameController =
        TextEditingController(text: data['lastName'] ?? '');
    final idNumberController =
        TextEditingController(text: data['idNumber'] ?? '');
    final careerController = TextEditingController(text: data['career'] ?? '');

    // ... (controladores para otros campos) ...
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Actualizar Usuario'),
          content: SingleChildScrollView(
            // Para que el contenido sea desplazable si es necesario
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
                TextField(
                  controller: idNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Número de Cédula'),
                ),
                TextField(
                  controller: careerController,
                  decoration: const InputDecoration(labelText: 'Carrera'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _updateUser(
                  document.id,
                  firstNameController.text,
                  emailController.text,
                  lastNameController.text,
                  idNumberController.text,
                  careerController.text,
                  _showSnackBar,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _updateUser(
  String userId,
  String firstName,
  String email,
  String lastName,
  String idNumber,
  String career,
  Function(String) showSnackBar,
) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'firstName': firstName,
      'email': email,
      'lastName': lastName,
      'idNumber': idNumber,
      'career': career,
    });
    // Llamar a la función para mostrar el SnackBar
    showSnackBar('Usuario actualizado con éxito');
  } catch (e) {
    // Mostrar SnackBar de error solo si el widget está montado
    showSnackBar('Usuario no se pudo actualizar');
  }
}
