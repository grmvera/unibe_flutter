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
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  int _currentPage = 0;
  final int _itemsPerPage = 5;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.searchController,
          focusNode: _focusNode,
          onChanged: (value) {
            setState(() {}); 
          },
          decoration: InputDecoration(
            hintText: 'Buscar estudiante por cédula...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Algo salió mal');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            var filteredDocs = snapshot.data!.docs.where((document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              final searchText = widget.searchController.text.toLowerCase();
              final idNumber = data['idNumber']?.toString().toLowerCase() ?? '';
              return idNumber.contains(searchText);
            }).toList();

            int startIndex = _currentPage * _itemsPerPage;
            int endIndex = startIndex + _itemsPerPage;
            if (endIndex > filteredDocs.length) {
              endIndex = filteredDocs.length;
            }
            var pageDocs = filteredDocs.sublist(startIndex, endIndex);

            return Column(
              children: [
                SizedBox(
                  height: 450,
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
                              'Apellidos',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Estado',
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
                              DataCell(Text(data['idNumber'] ?? '')), 
                              DataCell(
                                Text(
                                  "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: data['status']
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    data['status'] ? 'Activo' : 'Bloqueado',
                                    style: TextStyle(
                                      color: data['status']
                                          ? Colors.green[800]
                                          : Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  onPressed: () {
                                    final userId = document.id;
                                    final Map<String, dynamic> userData =
                                        document.data() as Map<String, dynamic>;

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
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Actualizar Usuario',
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
        ),
      ],
    );
  }
}
