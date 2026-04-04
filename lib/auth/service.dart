import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // This links to your new database
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userStatus => _auth.authStateChanges();

  // --- LOGIN ---
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  // --- REGISTER (Creates the Role) ---
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // This creates the "clickable" role field in your Firestore
      await _db.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      debugPrint("Register Error: $e");
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}
