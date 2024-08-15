import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unibe_app_control/Widget/botton_navigaton_bart.dart';
import '../Widget/form_table.dart';
import '../Widget/form_disabled_table.dart';

class FromSettings extends StatefulWidget {
  const FromSettings({super.key});

  @override
  _FromSettingsState createState() => _FromSettingsState();
}

class _FromSettingsState extends State<FromSettings> {
  final TextEditingController _fieldNameController = TextEditingController();
  String _fieldType = 'texto';
  String _fieldTargetType = 'estudiante'; // Nuevo campo para el tipo de usuario
  bool light = true;
  List<TextEditingController> _optionsControllers = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (reason) async {
        Navigator.pop(context, true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ajustes del Formulario'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildFieldNameInput(),
                _buildFieldTypeDropdown(),
                _buildFieldTargetTypeDropdown(), // Nuevo dropdown para el tipo de usuario
                if (_fieldType == 'dropdown') _buildDropdownOptions(),
                _buildAddFieldButton(),
                _buildFormToggleSwitch(),
                if (light) const FormTable() else const FormDisabledTable(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottonNavigatonBart(),
      ),
    );
  }

  Widget _buildFieldNameInput() {
    return TextField(
      controller: _fieldNameController,
      decoration: const InputDecoration(labelText: 'Nombre del Campo'),
    );
  }

  Widget _buildFieldTypeDropdown() {
    return DropdownButton<String>(
      value: _fieldType,
      onChanged: (String? newValue) {
        setState(() {
          _fieldType = newValue!;
        });
      },
      items: ['texto', 'dropdown'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildFieldTargetTypeDropdown() {
    return DropdownButton<String>(
      value: _fieldTargetType,
      onChanged: (String? newValue) {
        setState(() {
          _fieldTargetType = newValue!;
        });
      },
      items: ['estudiante', 'administrador']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownOptions() {
    return Column(
      children: [
        ..._optionsControllers.map(
          (controller) => TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Opción'),
          ),
        ),
        ElevatedButton(
          onPressed: _addDropdownOption,
          child: const Text('Agregar Opción'),
        ),
      ],
    );
  }

  Widget _buildAddFieldButton() {
    return ElevatedButton(
      onPressed: _createField,
      child: const Text('Agregar Campo'),
    );
  }

  Widget _buildFormToggleSwitch() {
    return Switch.adaptive(
      value: light,
      onChanged: (bool value) {
        setState(() {
          light = value;
        });
      },
    );
  }

  void _addDropdownOption() {
    setState(() {
      _optionsControllers.add(TextEditingController());
    });
  }

  Future<void> _createField() async {
    if (_isFieldNameEmpty() || _areDropdownOptionsInvalid()) {
      return;
    }

    final newField = {
      'label': _fieldNameController.text.trim(),
      'tipe_entry': _fieldType,
      'target_type': _fieldTargetType, // Guardar el tipo de usuario
      'options': _optionsControllers.map((e) => e.text.trim()).toList(),
      'status': true,
      'information_input': DateTime.now(),
      'information_output': '',
      'created': '',
      'update': '',
      'delete': '',
    };

    try {
      await FirebaseFirestore.instance.collection('form_settings').add(newField);
      _resetForm();
      _showSnackBar('Campo agregado correctamente');
    } catch (error) {
      _showSnackBar('Error al agregar campo');
    }
  }

  bool _isFieldNameEmpty() {
    if (_fieldNameController.text.trim().isEmpty) {
      _showSnackBar('El nombre del campo no puede estar vacío');
      return true;
    }
    return false;
  }

  bool _areDropdownOptionsInvalid() {
    if (_fieldType == 'dropdown' &&
        _optionsControllers.any((controller) => controller.text.trim().isEmpty)) {
      _showSnackBar('Las opciones del dropdown no pueden estar vacías');
      return true;
    }
    return false;
  }

  void _resetForm() {
    _fieldNameController.clear();
    _fieldType = 'texto';
    _fieldTargetType = 'estudiante'; // Resetear el tipo de usuario
    _optionsControllers = [TextEditingController()];
    setState(() {});
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
