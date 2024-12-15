import 'package:flutter/material.dart';
import '../Widget/custom_app_bar.dart';
import '../Widget/custom_drawer.dart';
import '../Widget/custom_bottom_navigation_bar.dart';
import '../Widget/user_table.dart';
import '../login/users_provider.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final usuarioProvider = Provider.of<UsuarioProvider>(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        userName: usuarioProvider.userData!['firstName'] ?? 'Usuario',
        userRole: usuarioProvider.userData!['role'] ?? 'Sin Rol',
        scaffoldKey: scaffoldKey,
      ),
      endDrawer: CustomDrawer(userData: usuarioProvider.userData!),
      body: _buildAdminView(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildAdminView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserTable(searchController: _searchController),
          ],
        ),
      ),
    );
  }
}
