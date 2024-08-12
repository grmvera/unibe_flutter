import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserStudent extends StatefulWidget {
  const UserStudent({Key? key}) : super(key: key);

  @override
  State<UserStudent> createState() => _UserStudentState();
}

class _UserStudentState extends State<UserStudent> {
  final Stream<QuerySnapshot> _userStudentStream = FirebaseFirestore.instance
      .collection('users_student')
      .where('status', isEqualTo: true)
      .snapshots();

  int _currentPage = 0;
  int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _userStudentStream,
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: 300,
                  child: DataTable(
                    columns: const[
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Cedula')),
                      DataColumn(label: Text('Aciones'))
                    ],
                    rows: pageDocs.map((DocumentSnapshot document){
                      Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                      return DataRow(
                        cells: [
                          DataCell(Text(data['Nombres'] ?? '')),
                          DataCell(Text(data['idNumber'] ?? '')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  onPressed: (){}, 
                                  icon: const Icon(Icons.add_call)
                                )
                              ],
                            )
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
        });
  }
}
