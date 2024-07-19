import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        _userData = snapshot.data();
        notifyListeners();
      }
    }
  }
}
