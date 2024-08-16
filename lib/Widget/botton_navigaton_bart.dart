import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../admin/admin_home_screen.dart';

class BottonNavigatonBart extends StatelessWidget {
  const BottonNavigatonBart({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Administración',
        ),
      ],
      selectedItemColor: const Color.fromARGB(255, 0, 4, 255),
      onTap: (int index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const HomeScreen()), // Reemplaza HomeScreen
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const AdminHomeScreen()), // Reemplaza AdminHomeScreen
          );
        }
      },
    );
  }
}
