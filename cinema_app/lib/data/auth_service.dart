import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Errore in signIn: ${e.message}');
    } catch (e) {
      debugPrint('Errore sconosciuto in signIn: $e');
    }
    return null;
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Errore in signUp: ${e.message}');
    } catch (e) {
      debugPrint('Errore sconosciuto in signUp: $e');
    }
    return null;
  }

  // Metodo di logout: controlla che la funzione abbia effettivamente questo nome nel tuo progetto!
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Errore nel logout: $e');
    }
  }
}