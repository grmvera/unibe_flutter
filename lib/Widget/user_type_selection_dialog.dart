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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageAccountsStudent(),
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
              icon: const Icon(Icons.school),
              label: const Text('Estudiante'),
            ),
            const SizedBox(width: 16), 
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageAccountsAdmin(),
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
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Administrador'),
            ),
          ],
        ),
      ],
    );
  }
}
