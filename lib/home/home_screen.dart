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
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = constraints.maxWidth * 0.9; 
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            _buildLargeActionButton(
              'Lista de Estudiantes',
              Icons.people,
              const Color(0xFFFCCC09),   
              textColor: const Color(0xFF00499C), 
              width: buttonWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminHomeScreen()),
                );
              },
            ),
            _buildLargeActionButton(
              'Crear Usuarios',
              Icons.person_add,
              const Color(0xFFFCCC09),   
              textColor: const Color(0xFF00499C), 
              width: buttonWidth,
              onTap: () {
                _showStudentDialog(context);
              },
            ),
            _buildLargeActionButton(
              'Bloquear y Desbloquear Estudiante',
              Icons.person_off,
              const Color(0xFFFCCC09),   
              textColor: const Color(0xFF00499C), 
              width: buttonWidth,
              onTap: () {
                BlockUnblockStudentsWidget.showBlockUnblockDialog(context);
              },
            ),
            _buildLargeActionButton(
              'Creación de Ciclo',
              Icons.event,
              const Color(0xFFFCCC09),   
              textColor: const Color(0xFF00499C), 
              width: buttonWidth,
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
      },
    );
  }

  Widget _buildLargeActionButton(
      String title, IconData icon, Color? backgroundColor,
      {Color? textColor, required VoidCallback onTap, required double width}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      width: width,
      height: 90.0, 
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor, 
          foregroundColor: textColor, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2.0,
        ),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16.0),
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: backgroundColor, size: 24.0),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0, 
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
          ],
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
              Column(
                children: [
                  _buildDialogButton(
                    context: dialogContext,
                    title: 'Crear Usuario',
                    icon: Icons.person_add,
                    backgroundColor: const Color(0xFFFCCC09),
                    textColor: const Color(0xFF00499C),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      showDialog(
                        context: dialogContext,
                        builder: (context) => const UserCreationScreen(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDialogButton(
                    context: dialogContext,
                    title: 'Cargar Archivo',
                    icon: Icons.upload_file,
                    backgroundColor: const Color(0xFFFCCC09),
                    textColor: const Color(0xFF00499C),
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
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: backgroundColor, size: 16.0),
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
