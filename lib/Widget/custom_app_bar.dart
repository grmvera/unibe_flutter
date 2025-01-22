import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userRole;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({
    super.key,
    required this.userName,
    required this.userRole,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Línea azul
        Container(
          color: const Color(0xFF1225F5),
          height: 5,
          width: double.infinity,
        ),
        AppBar(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'images/unibe_logo_am.png',
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $userName!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, 
                      maxLines: 1, 
                    ),
                    Text(
                      'Rol: $userRole',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState!.openEndDrawer();
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
