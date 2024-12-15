import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unibe_app_control/admin/updae_user_screen.dart';

class UserTable extends StatefulWidget {
  final TextEditingController searchController;

  const UserTable({
    super.key,
    required this.searchController,
  });

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('status', isEqualTo: true)
      .snapshots();

  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Algo salió mal');
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
            SizedBox(
              height: 450, // Altura fija para la tabla
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateColor.resolveWith(
                        (states) => Colors.grey[300]!),
                    dataRowColor: WidgetStateColor.resolveWith(
                        (states) => Colors.grey[100]!),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Cédula',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nombre Completo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Acciones',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: pageDocs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return DataRow(
                        cells: [
                          DataCell(Text(data['idNumber'] ?? '')), // Cédula
                          DataCell(
                            Text(
                              "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
                            ), // Nombre completo
                          ),
                          DataCell(
                            ElevatedButton(
                              onPressed: () {
                                final userId =
                                    document.id; // Identificador del usuario
                                final Map<String, dynamic> userData =
                                    document.data() as Map<String, dynamic>;

                                // Verificar que userId y userData no sean nulos antes de navegar
                                if (userId.isNotEmpty && userData.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateUserScreen(
                                        userId: userId,
                                        userData: userData,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Datos de usuario no válidos.')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Actualizar'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
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
}
