import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unibe_app_control/admin/deletedusersScreen.dart';
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
  final Stream<QuerySnapshot> _cyclesStream =
      FirebaseFirestore.instance.collection('cycles').snapshots();

  String? selectedCycleId;
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            return isSmallScreen
                ? Column(
                    children: [
                      _buildCycleDropdown(),
                      const SizedBox(height: 10),
                      _buildSearchField(),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: _buildCycleDropdown()),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: _buildSearchField()),
                    ],
                  );
          },
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Algo salió mal');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            var filteredDocs = snapshot.data!.docs.where((document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final searchText = widget.searchController.text.toLowerCase();
              final idNumber = data['idNumber']?.toString().toLowerCase() ?? '';
              final cycleId = data['cycleId']?.toString();

              final matchesSearch = idNumber.contains(searchText);
              final matchesCycle =
                  selectedCycleId == null || cycleId == selectedCycleId;

              final isNotDeleted = !(data['isDeleted'] ?? false);

              return matchesSearch && matchesCycle && isNotDeleted;
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
                  height: 295,
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
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        final userId = document.id;
                                        final Map<String, dynamic> userData =
                                            document.data()
                                                as Map<String, dynamic>;

                                        if (userId.isNotEmpty &&
                                            userData.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateUserScreen(
                                                userId: userId,
                                                userData: userData,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Datos de usuario no son válidos.')),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      tooltip: 'Actualizar Usuario',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(
                                            document.id);
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      tooltip: 'Eliminar Usuario',
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
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Anterior'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Página ${_currentPage + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: endIndex < filteredDocs.length
                              ? () => setState(() => _currentPage++)
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Siguiente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeletedUsersScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        'Ver Usuarios Eliminados',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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

  void _showDeleteConfirmationDialog(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Confirmar eliminación',
                      style: TextStyle(
                        fontSize: constraints.maxWidth < 600 ? 18 : 22,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                '¿Está seguro de que desea eliminar este usuario? Esta acción puede revertirse reactivando al usuario más tarde.',
                style: TextStyle(
                  fontSize: constraints.maxWidth < 600 ? 14 : 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: constraints.maxWidth < 600 ? 14 : 16,
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _setUserDeleted(userId);
                    Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: constraints.maxWidth < 600 ? 14 : 16,
                    ),
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _setUserDeleted(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isDeleted': true, 'status': false});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  Widget _buildCycleDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _cyclesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final cycles = snapshot.data!.docs;

        return DropdownButtonFormField<String>(
          value: selectedCycleId,
          decoration: InputDecoration(
            labelText: 'Seleccionar Ciclo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todos los ciclos'),
            ),
            ...cycles.where((cycle) => cycle['isActive'] == true).map((cycle) {
              // Filtrar solo los ciclos activos
              return DropdownMenuItem<String>(
                value: cycle.id,
                child: Text(cycle['name']),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              selectedCycleId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
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
    );
  }
}
