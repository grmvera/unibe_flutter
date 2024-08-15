import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FormTable extends StatefulWidget {
  const FormTable({super.key});

  @override
  State<FormTable> createState() => _FormTableState();
}

class _FormTableState extends State<FormTable> {
  final Stream<QuerySnapshot> _fromSettings = FirebaseFirestore.instance
      .collection('form_settings')
      .where('status', isEqualTo: true)
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
                    DataColumn(label: Text('Tipo Objeto')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: pageDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['label'] ?? '')),
                      DataCell(Text(data['tipe_entry'] ?? '')),
                      DataCell(Text(data['target_type'] ?? '')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showUpdateFormDialog(context, document);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.disabled_visible),
                            onPressed: () {
                              _disableForm(document.id);
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

  Future<void> _disableForm(String formId) async {
    try {
      await FirebaseFirestore.instance
          .collection('form_settings')
          .doc(formId)
          .update({'status': false});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Desactivado con Exito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al desactivar')),
      );
    }
  }
}

void _showUpdateFormDialog(BuildContext context, DocumentSnapshot document) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return _UpdateFormDialog(
          document: document,
          showSnackBar: (message) => _showSnackBar(context, message));
    },
  );
}

class _UpdateFormDialog extends StatefulWidget {
  final DocumentSnapshot document;
  final Function(String) showSnackBar;
  const _UpdateFormDialog(
      {super.key, required this.document, required this.showSnackBar});
  @override
  State<_UpdateFormDialog> createState() => _UpdateFormDialogState();
}

class _UpdateFormDialogState extends State<_UpdateFormDialog> {
  late TextEditingController labelController;
  late TextEditingController labelTipeController;
  late TextEditingController tipeEntryController;
  List<TextEditingController> optionControllers = [TextEditingController()];
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.document.data()! as Map<String, dynamic>;
    labelController = TextEditingController(text: data['label'] ?? '');
    tipeEntryController = TextEditingController(text: data['tipe_entry'] ?? '');
    labelTipeController = TextEditingController(text: data['target_type'] ?? '');
    if (data['options'] != null) {
      optionControllers = (data['options'] as List)
          .map((option) => TextEditingController(text: option))
          .toList();
    }
  }

  @override
  void dispose() {
    labelController.dispose();
    tipeEntryController.dispose();
    labelTipeController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizar Campo'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Etiqueta'),
              onChanged: (value) => setState(() {}),
            ),
            TextField(
              controller: labelTipeController,
              decoration: const InputDecoration(labelText: 'Tipo de Objeto'),
              onChanged: (value) => setState(() {}),
            ),
            TextField(
              controller: tipeEntryController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Entrada',
              ),
              enabled: false,
            ),
            
            if (tipeEntryController.text == 'dropdown')
              Column(
                children: [
                  ...optionControllers
                      .map((controller) => TextField(
                            controller: controller,
                            decoration:
                                const InputDecoration(labelText: 'Opción'),
                            onChanged: (value) => setState(() {}),
                          ))
                      .toList(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        optionControllers.add(TextEditingController());
                      });
                    },
                    child: const Text('Agregar Opción'),
                  ),
                ],
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
            _updateForm(
              widget.document.id,
              labelController.text,
              tipeEntryController.text,
              optionControllers.map((e) => e.text).toList(),
              widget.showSnackBar, // Pasamos la función showSnackBar
            );
            Navigator.of(context).pop();
          },
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  // Agregamos el parámetro context
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

Future<void> _updateForm(
  String formId,
  String label,
  String tipeEntry,
  List<String> options, // Cambia el tipo a List<String>
  Function(String) showSnackBar,
) async {
  try {
    await FirebaseFirestore.instance
        .collection('form_settings')
        .doc(formId)
        .update({
      'label': label,
      'tipe_entry': tipeEntry,
      'options': options, // Guarda la lista de opciones
      'information_output': DateTime.now(),
      'update': 'rodolfo'
    });
    showSnackBar('Campo actualizado con éxito');
  } catch (e) {
    showSnackBar('Error al actualizar el campo');
  }
}
