import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para usar kIsWeb
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
      BottomNavigationBarItem(
        icon: const Icon(Icons.home),
        label: 'Inicio',
        tooltip: 'Ir a Inicio',
      ),
      if (!kIsWeb && userRole != 'estudiante')
        BottomNavigationBarItem(
          icon: const Icon(Icons.camera_alt),
          label: 'Escanear',
          tooltip: 'Acceso a Cámara',
        ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: 'Perfil',
        tooltip: 'Ir a tu Perfil',
      ),
    ];

    final int adjustedIndex = currentIndex >= items.length ? 0 : currentIndex;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: adjustedIndex,
        onTap: (index) {
          if (!kIsWeb && userRole != 'estudiante' && index == 1) {
            // Navegar a la pantalla de cámara solo en dispositivos móviles
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );
          } else if ((!kIsWeb && userRole != 'estudiante' && index == 2) ||
              (kIsWeb && index == 1)) {
            // Navegar al perfil ajustando índices para web y móvil
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
        selectedItemColor: const Color(0xFF00499C),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
