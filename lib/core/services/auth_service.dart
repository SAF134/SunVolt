import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for auth changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Pastikan dokumen user ada di Firestore (buat jika belum ada)
  Future<void> _ensureUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final doc = await userDoc.get();

    if (!doc.exists) {
      await userDoc.set({
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'balance': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Dokumen user baru dibuat di Firestore: ${user.email}');
    }
  }

  // Handle Google Sign-In
  // google_sign_in v7.2.0 uses a singleton pattern with GoogleSignIn.instance
  // and the authenticate() method instead of signIn().
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final GoogleSignInAccount account = await googleSignIn.authenticate();

      // In v7.x, authentication is a synchronous getter
      final GoogleSignInAuthentication googleAuth = account.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _ensureUserDocument(userCredential.user!);
      }
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      // User membatalkan login — bukan error sesungguhnya
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        debugPrint('Google Sign-In dibatalkan oleh user.');
        return null;
      }
      debugPrint('GoogleSignInException: ${e.code} - ${e.description}');
      rethrow;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Handle Email/Password Login
  Future<User?> loginWithEmail({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _ensureUserDocument(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Login Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Login Error: $e');
      rethrow;
    }
  }

  // Handle Email/Password Registration
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
        await _ensureUserDocument(_auth.currentUser!);
      }
      
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Registration Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Registration Error: $e');
      rethrow;
    }
  }

  // Handle Sign-Out
  Future<void> signOut() async {
    try {
      // In v7.x, use the singleton instance directly
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }

  // Handle Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error sending password reset: $e');
      rethrow;
    }
  }
}
