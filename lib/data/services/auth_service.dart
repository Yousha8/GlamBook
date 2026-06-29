import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // SIGN UP
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        final newUser = UserModel(
          id: credential.user!.uid,
          fullName: fullName,
          email: email,
          phone: phone,
          role: UserRole.customer, // Default role
          profileImageUrl: profileImageUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.createUser(newUser);
      }
      return credential;
    } catch (e) {
      print('Auth Signup Error: $e');
      rethrow;
    }
  }

  // LOGIN
  Future<UserCredential?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Update last login
        final user = await _firestore.getUser(credential.user!.uid);
        if (user != null) {
          await _firestore.updateUser(user.copyWith(lastLoginAt: DateTime.now()));
        }
      }
      return credential;
    } catch (e) {
      print('Auth Login Error: $e');
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // RESET PASSWORD
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
