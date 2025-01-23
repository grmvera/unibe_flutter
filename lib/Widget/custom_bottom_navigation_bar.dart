import 'package:flutter/material.dart';
import 'package:unibe_app_control/Widget/camerascreen.dart';
import 'package:unibe_app_control/admin/profilescreen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Inicio',
      ),
      if (userRole != 'estudiante') 
        const BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Escanear',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

    final int adjustedIndex = currentIndex >= items.length ? 0 : currentIndex;

    return BottomNavigationBar(
      currentIndex: adjustedIndex, 
      onTap: (index) {
        if (userRole != 'estudiante' && index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        } else if (index == (userRole == 'estudiante' ? 1 : 2)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else {
          onTap(index);
        }
      },
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
    );
  }
}
