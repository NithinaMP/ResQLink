import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current logged in user
  User? get currentUser => _auth.currentUser;

  // Check if officer is logged in
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email and password
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // null means success!
    } on FirebaseAuthException catch (e) {
      // Return error message
      switch (e.code) {
        case 'user-not-found':
          return 'No officer found with this email';
        case 'wrong-password':
          return 'Wrong password';
        case 'invalid-email':
          return 'Invalid email format';
        case 'user-disabled':
          return 'This account has been disabled';
        default:
          return 'Login failed. Please try again';
      }
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}