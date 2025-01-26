import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  String? _token;
  bool _isLoading = false;

  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String? idToken = await user.getIdToken();
        _token = idToken;

        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          _userData = snapshot.data();
        } else {
          _userData = null;
          print('El documento del usuario no existe en Firestore.');
        }
      } else {
        _userData = null;
        _token = null;
        print('Usuario no autenticado.');
      }
    } catch (e) {
      _userData = null;
      _token = null;
      print('Error al obtener los datos del usuario: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
