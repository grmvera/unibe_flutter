import 'package:flutter/material.dart';
import '../admin/manage_accounts_student.dart';
import '../admin/manage_accounts_admin.dart';

class UserTypeSelectionDialog extends StatelessWidget {
  const UserTypeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text('Creación de Usuario'),
      ),
      content: const Text(
        'Selecciona el tipo de usuario que deseas crear:',
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageAccountsStudent(),
                  ),
                ); // Redirige al formulario de estudiantes
              },
              icon: const Icon(Icons.school),
              label: const Text('Estudiante'),
            ),
            const SizedBox(width: 16), // Espaciado entre botones
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageAccountsAdmin(),
                  ),
                ); // Redirige al formulario de administradores
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Administrador'),
            ),
          ],
        ),
      ],
    );
  }
}
