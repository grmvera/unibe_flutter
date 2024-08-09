import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../admin/form_settings.dart';

class ManageAccounts extends StatefulWidget {
  const ManageAccounts({super.key});

  @override
  _ManageAccounts createState() => _ManageAccounts();
}

class _ManageAccounts extends State<ManageAccounts> {
  @override
  Widget build(BuildContext constext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FromSettings(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Widget>>(
          future: obtenerCamposFormulario(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Correo'),
                    ),
                    TextField(
                      controller: _idNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Número de Cédula'),
                    ),
                    ...snapshot.data!, // Agrega los campos de Firebase aquí
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  final _emailController = TextEditingController();
  final _idNumberController = TextEditingController();
}

Future<List<Widget>> obtenerCamposFormulario() async {
  List<Widget> campos = [];
  CollectionReference configuracion =
      FirebaseFirestore.instance.collection('form_settings');
  QuerySnapshot snapshot =
      await configuracion.where('status', isEqualTo: true).get();
  for (var doc in snapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['tipe_entry'] == 'texto') {
      campos.add(
          TextField(decoration: InputDecoration(labelText: data['label'])));
    } else if (data['tipe_entry'] == 'dropdown') {
      // Asegúrate de que data['options'] sea una lista de cadenas
      List<String> options = (data['options'] as List).map((e) => e.toString()).toList();
      campos.add(DropdownButton<String>(
        value: options[0], // Usa el primer elemento de la lista de opciones
        onChanged: (String? newValue) {
          // Lógica para actualizar el valor seleccionado
        },
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
      ));
    }
  }
  return campos;
}
