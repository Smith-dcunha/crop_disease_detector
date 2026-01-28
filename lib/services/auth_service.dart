import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to create user'};
      }

      // Update display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'totalScans': 0,
        'diseasesDetected': 0,
        'syncEnabled': true,
      });

      return {'success': true, 'user': user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to sign in'};
      }

      // Update last login
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'user': user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// Sign in anonymously (guest mode)
  Future<Map<String, dynamic>> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to sign in anonymously'};
      }

      // Create anonymous user document
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'isAnonymous': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'totalScans': 0,
        'diseasesDetected': 0,
        'syncEnabled': false,
      });

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Password reset email sent'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile: $e'};
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Update user statistics
  Future<void> updateUserStats({
    int? totalScans,
    int? diseasesDetected,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{};
      if (totalScans != null) {
        updates['totalScans'] = FieldValue.increment(totalScans);
      }
      if (diseasesDetected != null) {
        updates['diseasesDetected'] = FieldValue.increment(diseasesDetected);
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  /// Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete all user scans
      final scansQuery = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var doc in scansQuery.docs) {
        await doc.reference.delete();
      }

      // Delete user account
      await user.delete();

      return {'success': true, 'message': 'Account deleted successfully'};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return {
          'success': false,
          'message': 'Please sign in again to delete your account',
          'requiresReauth': true,
        };
      }
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete account: $e'};
    }
  }

  /// Convert anonymous account to permanent
  Future<Map<String, dynamic>> convertAnonymousAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || !user.isAnonymous) {
        return {'success': false, 'message': 'No anonymous user to convert'};
      }

      // Link with email/password credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);
      await user.updateDisplayName(name);

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        'email': email,
        'name': name,
        'isAnonymous': false,
        'syncEnabled': true,
        'convertedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Account converted successfully'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Failed to convert account: $e'};
    }
  }

  /// Get error message from Firebase error code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Please use a stronger password (at least 6 characters).';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}