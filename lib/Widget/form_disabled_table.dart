import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FormDisabledTable extends StatefulWidget {
  const FormDisabledTable({super.key});

  @override
  State<FormDisabledTable> createState() => _FormDisabledTableState();
}

class _FormDisabledTableState extends State<FormDisabledTable> {
  final Stream<QuerySnapshot> _fromSettings = FirebaseFirestore.instance
      .collection('form_settings')
      .where('status', isEqualTo: false)
      .snapshots();

  int _currentPage = 0;
  int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fromSettings,
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
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                height: 300,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Etiqueta')),
                    DataColumn(label: Text('Tipo de Entrada')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: pageDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['label'] ?? '')),
                      DataCell(Text(data['tipe_entry'] ?? '')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteForm(document.id);
                            },
                          ), IconButton(
                            icon: const Icon(Icons.approval_rounded),
                            onPressed: () {
                              _enableForm(document.id);
                            },
                          )
                        ],
                      ))
                    ]);
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

  Future<void> _deleteForm(String formId) async {
    try {
      await FirebaseFirestore.instance
          .collection('form_settings')
          .doc(formId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elimina con Exito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al elimnar')),
      );
    }
  }

  Future<void> _enableForm(String formId) async {
    try {
      await FirebaseFirestore.instance
          .collection('form_settings')
          .doc(formId)
          .update({'status': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actulizado con Exito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al Actualizar')),
      );
    }
  }
}
