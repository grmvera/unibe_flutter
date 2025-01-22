import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteUserDialog extends StatelessWidget {
  final String userId;
  final String userUid;

  const DeleteUserDialog({
    Key? key,
    required this.userId,
    required this.userUid,
  }) : super(key: key);

  Future<void> _deleteUser(BuildContext context, String? userUid) async {
    if (userUid == null || userUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: UID del usuario es nulo o vacío')),
      );
      return;
    }

    try {
      const String url = 'https://us-central1-controlacceso-403b0.cloudfunctions.net/deleteUser';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{'uid': userUid}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al eliminar usuario: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Confirmar Eliminación',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: constraints.maxWidth < 600 ? 18 : 22,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: constraints.maxWidth < 600 ? 14 : 16,
                ),
              ),
              const SizedBox(height: 15),
              Icon(
                Icons.delete_forever,
                size: constraints.maxWidth < 600 ? 30 : 40,
                color: Colors.red,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: TextStyle(
                  fontSize: constraints.maxWidth < 600 ? 14 : 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: TextStyle(
                  fontSize: constraints.maxWidth < 600 ? 14 : 16,
                ),
              ),
              onPressed: () {
                _deleteUser(context, userUid);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
