import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false; // Indica si los datos se están cargando

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading; // Getter para el estado de carga

  Future<void> fetchUserData() async {
    _isLoading = true; // Cambia el estado a cargando
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        _userData = snapshot.data();
      }
    }

    _isLoading = false; // Finaliza el estado de carga
    notifyListeners();
  }
}
