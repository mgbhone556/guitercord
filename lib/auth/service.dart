import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Stream to track login status
  Stream<firebase_auth.User?> get userStatus => _auth.authStateChanges();

  // Login
  Future<firebase_auth.User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  // Register
  Future<firebase_auth.User?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint("Register Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async => await _auth.signOut();
}
