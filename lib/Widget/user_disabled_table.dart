import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDisabledTable extends StatefulWidget {
  const UserDisabledTable({Key? key}) : super(key: key);

  @override
  State<UserDisabledTable> createState() => _UserDisabledTableState();
}

class _UserDisabledTableState extends State<UserDisabledTable> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('status', isEqualTo: false)
      .snapshots();

  int _currentPage = 0;
  int _itemsPerPage = 5;

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
        var filteredDocs = snapshot.data!.docs;
        int startIndex = _currentPage * _itemsPerPage;
        int endIndex = startIndex + _itemsPerPage;
        if (endIndex > filteredDocs.length) {
          endIndex = filteredDocs.length;
        }
        var pageDocs = filteredDocs.sublist(startIndex, endIndex);
        return Column(
          children: [
            SingleChildScrollView(
              // Aquí añadimos el SingleChildScrollView
              scrollDirection: Axis.horizontal, //  y especificamos la dirección
              child: SizedBox(
                height: 300,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Cedula')),
                    DataColumn(label: Text('Correo')),
                    DataColumn(label: Text('Aciones')),
                  ],
                  rows: pageDocs.map((DocumentSnapshot document) {
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
                                  _activeUser(document.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  _deleteUser(document.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text('Página ${_currentPage + 1}'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: endIndex < filteredDocs.length
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar usuario de Firestore
  Future<void> _activeUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'status': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario activado con éxito')),
      );
    } catch (e) {
      print('Error al activar el usuario: $e');
      // Puedes mostrar un mensaje de error si lo deseas
    }
  }

  Future<void> _deleteUser(String userId) async {
    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que quieres eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el diálogo
                try {
                  // 1. Obtener el correo electrónico del usuario a eliminar de Firestore
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();
                  final userEmail = userDoc.data()?['email'];
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .delete();
                  // 3. Obtener la instancia del usuario de Authentication usando el correo electrónico
                  /*if (userEmail != null) {
                    final user = await FirebaseAuth.instance.fetchSignInMethodsForEmail(userEmail);
                    if (user.isNotEmpty) {
                      await FirebaseAuth.instance.currentUser
                          ?.reauthenticateWithCredential(
                              EmailAuthProvider.credential(
                                  email: userEmail,
                                  password:'')); // Requiere la contraseña del usuario
                      await FirebaseAuth.instance.currentUser?.delete();
                    }
                  }*/
                  _showSnackBar('Usuario eliminado con éxito');
                } catch (e) {
                  _showSnackBar('Error al eliminar usuario: $e');
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
