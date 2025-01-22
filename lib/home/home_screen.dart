import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibe_app_control/Widget/block_unblock_widget.dart';
import 'package:unibe_app_control/admin/admin_home_screen.dart';
import 'package:unibe_app_control/admin/cyclemanagementscreen.dart';
import 'package:unibe_app_control/admin/userscreatecreen.dart';
import '../login/users_provider.dart';
import '../login/change_password.dart';
import '../Widget/custom_drawer.dart';
import '../Widget/student_view.dart';
import '../Widget/custom_app_bar.dart';
import '../Widget/custom_bottom_navigation_bar.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

    final userData = usuarioProvider.userData;
    if (userData == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Error: No se pudieron cargar los datos del usuario.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final bool isStudent = usuarioProvider.userData!['role'] == 'estudiante';

    final List<Widget> screens = [
      isStudent
          ? StudentView(
              userData: usuarioProvider.userData!,
              showAppBar: false,
              showDetails: false,
            )
          : _buildAdminView(),
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
        userName: usuarioProvider.userData?['firstName'] ?? 'Usuario',
        userRole: usuarioProvider.userData?['role'] ?? 'Sin Rol',
        scaffoldKey: scaffoldKey,
      ),
      endDrawer: CustomDrawer(userData: usuarioProvider.userData!),
      body: screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userRole: usuarioProvider.userData!['role'],
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
          'Bloquear y Desbloquear Estudiante',
          Icons.person_off,
          const Color(0xFF1225F5),
          onTap: () {
            BlockUnblockStudentsWidget.showBlockUnblockDialog(context);
          },
        ),
        _buildLargeActionButton(
          'Creación de Ciclo',
          Icons.event,
          const Color(0xFF1225F5),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CycleManagementScreen()),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.group_add,
                color: Color(0xFF1225F5),
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Gestión de Usuarios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué deseas realizar?\nSelecciona una de las siguientes opciones:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildDialogButton(
                    context: dialogContext,
                    title: 'Crear Usuario',
                    icon: Icons.person_add,
                    color: const Color(0xFF1225F5),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      showDialog(
                        context: dialogContext,
                        builder: (context) => const UserCreationScreen(),
                      );
                    },
                  ),
                  _buildDialogButton(
                    context: dialogContext,
                    title: 'Cargar Archivo',
                    icon: Icons.upload_file,
                    color: const Color(0xFF27AE60),
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
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    );
  }
}
