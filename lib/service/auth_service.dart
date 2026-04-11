import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Stream<User?> get userStatus => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final List<String> scopes = <String>['email', 'profile'];
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(scopes);
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: authorization?.accessToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        await _updateUserData(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _updateUserData(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await userRef.update({'lastSignIn': FieldValue.serverTimestamp()});
    }
  }
}
