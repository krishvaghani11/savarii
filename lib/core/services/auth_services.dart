import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
// import models
// services/auth_service.dart
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  Future<UserCredential> loginWithEmailPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }
}