import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Widget/form_table.dart';
import '../login/users_provider.dart';
import '../Widget/form_disabled_table.dart';

class FromSettings extends StatefulWidget {
  const FromSettings({super.key});

  @override
  _FromSettingsState createState() => _FromSettingsState();
}

class _FromSettingsState extends State<FromSettings> {
  final _fieldNameController = TextEditingController();
  final usuarioProvider = UsuarioProvider();

  String _fieldType = 'texto';
  bool light = true;
  List<TextEditingController> _optionsControllers = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes del Formulario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _fieldNameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Campo'),
              ),
              DropdownButton<String>(
                value: _fieldType,
                onChanged: (String? newValue) {
                  setState(() {
                    _fieldType = newValue!;
                  });
                },
                items: <String>['texto', 'dropdown']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (_fieldType == 'dropdown')
                Column(
                  children: [
                    ..._optionsControllers.map((controller) => TextField(
                          controller: controller,
                          decoration:
                              const InputDecoration(labelText: 'Opción'),
                        )),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _optionsControllers.add(TextEditingController());
                        });
                      },
                      child: const Text('Agregar Opción'),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance.collection('form_settings').add({
                    'label': _fieldNameController.text,
                    'tipe_entry': _fieldType,
                    'options': _optionsControllers.map((e) => e.text).toList(),
                    'status': true,
                    'information_input': DateTime.now(),
                    'information_output': '',
                    'created': 'rodolfo',
                    'update': '',
                    'delete': '',
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Campo agregado correctamente')),
                    );
                    _fieldNameController.clear();
                    _fieldType = 'texto';
                    _optionsControllers = [TextEditingController()];
                    setState(() {});
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al agregar campo')),
                    );
                  });
                },
                child: const Text('Agregar Campo'),
              ),
              Switch.adaptive(
                value: light,
                onChanged: (bool value) {
                  setState(() {
                    light = value;
                  });
                },
              ),
              if (light == true)
                const FormTable()
              else
                (const FormDisabledTable())
            ],
          ),
        ),
      ),
    );
  }
}
