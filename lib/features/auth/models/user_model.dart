import 'package:cloud_firestore/cloud_firestore.dart';

class WizzyUser {
  final String uid;
  final String username;
  final String email;
  final String whatsapp;
  final String photoUrl;
  final int points;
  final DateTime? createdAt; // Le "?" signifie qu'il peut être nul au début

  WizzyUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.whatsapp,
    this.photoUrl =
        "https://ui-avatars.com/api/?name=Wizzy&background=6200EE&color=fff",
    this.points = 0,
    this.createdAt, // AJOUTÉ ICI : Il est maintenant initialisé
  });

  // Convertir l'objet en Map pour l'envoyer à Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'whatsapp': whatsapp,
      'photoUrl': photoUrl,
      'points': points,
      // Si createdAt est nul, on demande à Firebase de mettre l'heure du serveur
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Créer un objet WizzyUser à partir des données reçues de Firestore
  factory WizzyUser.fromMap(Map<String, dynamic> map) {
    return WizzyUser(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      points: map['points'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
