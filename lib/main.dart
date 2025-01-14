import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:unibe_app_control/login/login_screen.dart';
import 'package:unibe_app_control/login/users_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verificar si Firebase ya está inicializado
  if (Firebase.apps.isEmpty) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Inicialización para Android
      await Firebase.initializeApp();
    } else {
      // Inicialización para Web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCKlfxoBBoznCsmXbjXd1t1XkbfSwu1kCg",
          authDomain: "controlacceso-403b0.firebaseapp.com",
          databaseURL: "https://controlacceso-403b0-default-rtdb.firebaseio.com",
          projectId: "controlacceso-403b0",
          storageBucket: "controlacceso-403b0.appspot.com",
          messagingSenderId: "715882159378",
          appId: "1:715882159378:web:d23ae4e5520a72e82b67cb",
          measurementId: "G-3W9RDE6RBM", // Opcional
        ),
      );
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
      ],
      child: MaterialApp(
        title: 'Unibe App Control',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        supportedLocales: const [
          Locale('en', 'US'), // Inglés
          Locale('es', 'ES'), // Español
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/logo_unibe.png',
              width: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 150),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1225F5),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'INGRESAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
