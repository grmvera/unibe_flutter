import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Widget/custom_app_bar.dart';
import '../Widget/custom_drawer.dart';
import '../Widget/custom_bottom_navigation_bar.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';

class CycleManagementScreen extends StatefulWidget {
  const CycleManagementScreen({Key? key}) : super(key: key);

  @override
  State<CycleManagementScreen> createState() => _CycleManagementScreenState();
}

class _CycleManagementScreenState extends State<CycleManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAutoDeactivateTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAutoDeactivateTimer() {
    _timer = Timer.periodic(const Duration(hours: 1), (timer) async {
      final now = DateTime.now();
      final querySnapshot =
          await FirebaseFirestore.instance.collection('cycles').get();

      for (var doc in querySnapshot.docs) {
        final endDate = DateTime.parse(doc['endDate']);
        final isActive = doc['isActive'] ?? true;

        if (now.isAfter(endDate) && isActive) {
          await FirebaseFirestore.instance
              .collection('cycles')
              .doc(doc.id)
              .update({'isActive': false});
        } else if (now.isBefore(endDate) && !isActive) {
          await FirebaseFirestore.instance
              .collection('cycles')
              .doc(doc.id)
              .update({'isActive': true});
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _createCycle() async {
    final String name = nameController.text.trim();

    if (name.isEmpty || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final now = DateTime.now();
      final isActive = now.isBefore(endDate!);

      await FirebaseFirestore.instance.collection('cycles').add({
        'name': name,
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'isActive': isActive,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ciclo creado exitosamente')),
      );
      nameController.clear();
      setState(() {
        startDate = null;
        endDate = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear el ciclo')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleCycleStatus(String cycleId, bool isActive) async {
    try {
      await FirebaseFirestore.instance
          .collection('cycles')
          .doc(cycleId)
          .update({'isActive': !isActive});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive
              ? 'Ciclo desactivado exitosamente'
              : 'Ciclo activado exitosamente'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el ciclo')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final userData = usuarioProvider.userData;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        userName: userData != null
            ? userData['firstName'] ?? 'Usuario'
            : 'Cargando...',
        userRole:
            userData != null ? userData['role'] ?? 'Sin Rol' : 'Cargando...',
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: CustomDrawer(
        userData: userData ?? {},
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userRole: usuarioProvider.userData!['role'],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Nuevo Ciclo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Ciclo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    startDate == null
                        ? 'Seleccionar Fecha de Inicio'
                        : 'Fecha de Inicio: ${startDate!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    endDate == null
                        ? 'Seleccionar Fecha de Finalización'
                        : 'Fecha de Finalización: ${endDate!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLoading ? Colors.grey[400] : const Color(0xFF1225F5),
                    disabledBackgroundColor: Colors.grey[400],
                    elevation: 5, // Añade una ligera sombra
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: isLoading ? null : _createCycle,
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Guardando...',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Guardar Ciclo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Ciclos Existentes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('cycles').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final cycles = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cycles.length,
                    itemBuilder: (context, index) {
                      final cycle = cycles[index];
                      final isActive = cycle['isActive'] ?? true;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(cycle['name']),
                          subtitle: Text(
                            'Desde: ${cycle['startDate'].toString().split('T')[0]}\nHasta: ${cycle['endDate'].toString().split('T')[0]}\nEstado: ${isActive ? 'Activo' : 'Inactivo'}',
                          ),
                          trailing: Wrap(
                            spacing: 8, // Espaciado entre botones
                            children: [
                              IconButton(
                                icon: Icon(
                                  isActive ? Icons.toggle_off : Icons.toggle_on,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                                onPressed: () =>
                                    _toggleCycleStatus(cycle.id, isActive),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('cycles')
                                      .doc(cycle.id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Ciclo eliminado')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
