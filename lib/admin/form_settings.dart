import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unibe_app_control/Widget/botton_navigaton_bart.dart';
import '../Widget/form_table.dart';
import '../Widget/form_disabled_table.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
              children: <Widget>[
                _buildFieldNameInput(),
                const SizedBox(height: 16),
                _buildFieldTargetTypeDropdown(),
                const SizedBox(height: 16),
                _buildFieldTypeDropdown(),
                const SizedBox(height: 16),
                if (_fieldType == 'dropdown') _buildDropdownOptions(),
                const SizedBox(height: 16),
                _buildAddFieldButton(),
                const SizedBox(height: 16),
                _buildToggleSwitch(),
                if (light == true)
                  const FormTable()
                else
                  const FormDisabledTable(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottonNavigatonBart(),
      ),
    );
  }

  final List<String> fieldTypes = ['texto', 'dropdown'];
  final List<String> targetTypes = ['estudiante', 'administrador'];

  String? selectedFieldType;
  String? selectedTargetType;

  Widget _buildFieldTypeDropdown() {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      value: selectedFieldType ?? fieldTypes[0],
      onChanged: (String? newValue) {
        setState(() {
          selectedFieldType = newValue!;
          _fieldType = newValue;
        });
      },
      items: fieldTypes
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              ))
          .toList(),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildFieldTargetTypeDropdown() {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      value: selectedTargetType ?? targetTypes[0],
      onChanged: (String? newValue) {
        setState(() {
          selectedTargetType = newValue!;
          _fieldTargetType = newValue;
        });
      },
      items: targetTypes
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              ))
          .toList(),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildFieldNameInput() {
    return TextFormField(
      controller: _fieldNameController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        hintText: 'Nombre del campo',
        hintStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildDropdownOptions() {
    return Column(
      children: [
        ..._optionsControllers.map(
          (controller) => TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Nombre de la opcion',
              hintStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addDropdownOption,
          icon: const Icon(Icons.exposure_plus_1),
          label: const Text('Agregar Opcion'),
        ),
      ],
    );
  }

  Widget _buildAddFieldButton() {
    return ElevatedButton.icon(
      onPressed: _createField,
      icon: const Icon(Icons.save_alt),
      label: const Text('Agregar'),
    );
  }

  Widget _buildToggleSwitch() {
    return ToggleSwitch(
      initialLabelIndex: light ? 0 : 1,
      totalSwitches: 2,
      labels: const ['Habilitado', 'Inhabilitado'],
      onToggle: (index) {
        setState(() {
          light = index == 0;
        });
      },
      fontSize: 12.0, // Aumenta el tamaño del texto
      minWidth: 100.0, // Aumenta el ancho de cada toggle
      minHeight: 35.0, // Aumenta la altura del toggle
      customTextStyles: const [
        TextStyle(
          color: Colors.white,
          fontSize: 12.0, // Ajusta el tamaño del texto
          fontWeight: FontWeight.bold,
        ),
        TextStyle(
          color: Colors.white,
          fontSize: 12.0, // Ajusta el tamaño del texto
          fontWeight: FontWeight.bold,
        ),
      ],
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
      'status': light,
      'information_input': DateTime.now(),
      'information_output': '',
      'created': '',
      'update': '',
      'delete': '',
    };

    try {
      await FirebaseFirestore.instance
          .collection('form_settings')
          .add(newField);
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
        _optionsControllers
            .any((controller) => controller.text.trim().isEmpty)) {
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
