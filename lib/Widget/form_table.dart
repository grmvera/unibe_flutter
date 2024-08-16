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
        const SnackBar(content: Text('Desactivado con Éxito')),
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
  late TextEditingController tipeEntryController;
  late String targetType;
  List<TextEditingController> optionControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.document.data()! as Map<String, dynamic>;
    labelController = TextEditingController(text: data['label'] ?? '');
    tipeEntryController = TextEditingController(text: data['tipe_entry'] ?? '');
    targetType = data['target_type'] ?? 'estudiante';
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
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                hintText: 'Nombre del campo',
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: targetType,
              onChanged: (String? newValue) {
                setState(() {
                  targetType = newValue!;
                });
              },
              items: <String>['estudiante', 'administrador']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Tipo Objeto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tipeEntryController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                label: const Text('Tipo de Entrada'),
                hintText: 'Nombre de la opcion',
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            if (tipeEntryController.text == 'dropdown')
              Column(
                children: [
                  ...optionControllers.map((controller) => TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          hintText: 'Nombre de la opcion',
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      )),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        optionControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.exposure_plus_1),
                    label: const Text('Agregar Opcion'),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar'),
        ),
        TextButton.icon(
          onPressed: () {
            _updateForm(
              widget.document.id,
              labelController.text,
              tipeEntryController.text,
              targetType,
              optionControllers.map((e) => e.text).toList(),
              widget.showSnackBar,
            );
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.system_update_tv_rounded),
          label: const Text('Actualizar'),
        ),
      ],
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

Future<void> _updateForm(
  String formId,
  String label,
  String tipeEntry,
  String targetType,
  List<String> options,
  Function(String) showSnackBar,
) async {
  try {
    await FirebaseFirestore.instance
        .collection('form_settings')
        .doc(formId)
        .update({
      'label': label,
      'tipe_entry': tipeEntry,
      'target_type': targetType,
      'options': options,
      'information_output': DateTime.now(),
      'update': 'rodolfo'
    });
    showSnackBar('Campo actualizado con éxito');
  } catch (e) {
    showSnackBar('Error al actualizar el campo');
  }
}
