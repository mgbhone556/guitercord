import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Stream<User?> get userStatus => _auth.authStateChanges();
  // Change your initialization line to this:

  // If the error persists with the line above, try:
  // final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Inside your signInWithGoogle method:
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Initialize (Mandatory in v7+)
      await GoogleSignIn.instance.initialize();

      // 2. Trigger the login flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();
      if (googleUser == null) return null;

      // 3. Get Authentication (This now ONLY contains the idToken)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Get Authorization (This is where the accessToken now lives)
      // You must define the scopes you are requesting access for
      final List<String> scopes = <String>['email', 'profile'];
      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizationForScopes(scopes);

      // 5. Create the Firebase Credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // Access the token from the new authorization object
        accessToken: authorization?.accessToken,
      );

      // 6. Sign in to Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

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

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
