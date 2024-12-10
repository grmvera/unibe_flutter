import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibe_app_control/admin/admin_home_screen.dart';
import '../login/users_provider.dart';
import '../login/change_password.dart';
import '../Widget/custom_drawer.dart';
import '../Widget/student_view.dart';
import '../Widget/custom_app_bar.dart';
import '../Widget/custom_bottom_navigation_bar.dart';
import '../Widget/user_type_selection_dialog.dart';
import '../Widget/excel_uploader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    usuarioProvider.fetchUserData().then((_) {
      if (usuarioProvider.userData != null &&
          usuarioProvider.userData!['isFirstLogin'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChangePassword()),
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // Lista de pantallas para la navegación inferior
    final List<Widget> _screens = [
      usuarioProvider.userData != null
          ? (usuarioProvider.userData!['role'] == 'admin'
              ? _buildAdminView()
              : StudentView(userData: usuarioProvider.userData!))
          : const Center(
              child: CircularProgressIndicator(),
            ),
      const Center(
        child: Text('Escanear QR', style: TextStyle(fontSize: 20)),
      ),
      const Center(
        child: Text('Perfil', style: TextStyle(fontSize: 20)),
      ),
    ];

    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        userName: usuarioProvider.userData!['firstName'],
        userRole: usuarioProvider.userData!['role'],
        scaffoldKey: scaffoldKey,
      ),
      endDrawer: CustomDrawer(userData: usuarioProvider.userData!),
      body: _screens[_selectedIndex], // Carga la pantalla según el índice
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

// Vista para el administrador
  Widget _buildAdminView() {
    return ListView(
      children: [
        _buildLargeActionButton(
          'Lista de Estudiantes',
          Icons.people,
          Colors.lightBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          },
        ),
        _buildLargeActionButton(
          'Crear Estudiante',
          Icons.person_add,
          Colors.green,
          onTap: () {
            _showStudentDialog(context);
          },
        ),
        _buildLargeActionButton(
          'Bloquear Estudiante',
          Icons.person_off,
          Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          },
        ),
        _buildLargeActionButton(
          'Creación de Ciclo',
          Icons.event,
          Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          },
        ),
      ],
    );
  }

// Botones de acción personalizados
  Widget _buildLargeActionButton(String title, IconData icon, Color color,
      {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

//Dialogo para crear estudiante
  void _showStudentDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Center(
          child: Text('Creación de Estudiante'),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aquí podrás cargar un archivo Excel con la lista de estudiantes, y el sistema los creará automáticamente.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Wrap(
            spacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: dialogContext,
                    builder: (context) => const UserTypeSelectionDialog(),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Crear Usuario'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showDialog(
                    context: dialogContext,
                    builder: (context) => const AlertDialog(
                      title: Text('Cargar Archivo'),
                      content: ExcelUploader(),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Cargar Archivo'),
              ),
            ],
          ),
        ],
      );
    },
  );
}

}
