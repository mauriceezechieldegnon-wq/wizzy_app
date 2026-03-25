import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wizzy/features/auth/models/user_model.dart';

class AuthService {
  // Ces trois lignes DOIVENT être à l'intérieur de la classe
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream pour suivre l'utilisateur
  Stream<User?> get userStream => _auth.authStateChanges();

  // Inscription
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String whatsapp,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    WizzyUser newUser = WizzyUser(
      uid: credential.user!.uid,
      username: username,
      email: email,
      whatsapp: whatsapp,
    );

    await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
  }

  // Connexion Google
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        WizzyUser newUser = WizzyUser(
          uid: user.uid,
          username: user.displayName ?? "Joueur",
          email: user.email!,
          whatsapp: "",
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
    }
  }

  // Réinitialisation mot de passe
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Déconnexion
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
