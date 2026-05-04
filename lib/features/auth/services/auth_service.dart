import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'dart:io'; // Pour Platform

// Remplace 'wizzy' par ton nom de projet si nécessaire
import 'package:wizzy/features/auth/models/user_model.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ON NE CRÉE PAS L'INSTANCE TOUT DE SUITE
  GoogleSignIn? _googleSignInInstance;

  // --- GETTER SÉCURISÉ POUR GOOGLE SIGN-IN ---
  // Cette fonction vérifie la plateforme avant de réveiller le plugin
  GoogleSignIn? get _googleSignIn {
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
    _googleSignInInstance ??= GoogleSignIn();
    return _googleSignInInstance;
  }
  // Ne pas renvoyer null, mais un objet qui prévient l'utilisateur
  return null; 
}

  // --- INSCRIPTION PAR EMAIL ---
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String whatsapp,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      WizzyUser newUser = WizzyUser(
        uid: credential.user!.uid,
        username: username,
        email: email,
        whatsapp: whatsapp,
        points: 0,
      );

      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
    } catch (e) {
      debugPrint("Erreur Inscription Email : $e");
      rethrow;
    }
  }

  // --- CONNEXION GOOGLE (SÉCURISÉE POUR WINDOWS) ---
  Future<void> signInWithGoogle() async {
    // Vérification de sécurité pour Windows
    final signInTool = _googleSignIn;
    if (signInTool == null) {
      debugPrint("Google Sign-In n'est pas supporté sur cette plateforme.");
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await signInTool.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          WizzyUser newUser = WizzyUser(
            uid: user.uid,
            username: user.displayName ?? "Champion",
            email: user.email!,
            whatsapp: "", 
          );
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        }
      }
    } catch (e) {
      debugPrint("Erreur Google Sign-In : $e");
      rethrow;
    }
  }

  // --- DÉCONNEXION ---
  Future<void> signOut() async {
    try {
      // On déconnecte Google uniquement si l'instance existe
      await _googleSignInInstance?.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Erreur lors de la déconnexion : $e");
    }
  }
}
