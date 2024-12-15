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

    if (usuarioProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (usuarioProvider.userData == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Error: No se pudieron cargar los datos del usuario.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final List<Widget> screens = [
      usuarioProvider.userData!['role'] == 'admin'
          ? _buildAdminView()
          : StudentView(userData: usuarioProvider.userData!),
      const Center(
        child: Text('Escanear QR', style: TextStyle(fontSize: 20)),
      ),
      const Center(
        child: Text('Perfil', style: TextStyle(fontSize: 20)),
      ),
    ];

    return Scaffold(
      key: scaffoldKey,
      appBar: usuarioProvider.userData != null
          ? CustomAppBar(
              userName: usuarioProvider.userData!['firstName'] ?? 'Usuario',
              userRole: usuarioProvider.userData!['role'] ?? 'Sin Rol',
              scaffoldKey: scaffoldKey,
            )
          : null,
      endDrawer: CustomDrawer(userData: usuarioProvider.userData!),
      body: screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }


  Widget _buildAdminView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: [
        _buildLargeActionButton(
          'Lista de Estudiantes',
          Icons.people,
          const Color(0xFF1225F5),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          },
        ),
        _buildLargeActionButton(
          'Crear Usarios',
          Icons.person_add,
          const Color(0xFF1225F5),
          onTap: () {
            _showStudentDialog(context);
          },
        ),
        _buildLargeActionButton(
          'Bloquear Estudiante',
          Icons.person_off,
          const Color(0xFF1225F5),
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
          const Color(0xFF1225F5),
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

  Widget _buildLargeActionButton(String title, IconData icon, Color color,
      {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text('Gestión de Usuarios'),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aquí podrás cargar un archivo Excel con la lista de estudiantes o crear usuarios de forma manual.',
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
                    Navigator.pop(dialogContext);
                    showDialog(
                      context: dialogContext,
                      builder: (context) => const UserTypeSelectionDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1225F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1225F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
