import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Initialize user profile in Firestore
      if (userCredential.user != null) {
        await FirestoreService.initializeUserProfile(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user profile in Firestore
      if (userCredential.user != null) {
        await FirestoreService.createUserProfile(
          uid: userCredential.user!.uid,
          email: email,
          displayName: displayName,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Try to set user offline in Firestore, but don't fail if it doesn't work
      try {
        await FirestoreService.setUserOffline();
      } catch (e) {
        // Log the error but continue with sign out
        print('Warning: Could not set user offline in Firestore: $e');
      }

      // Sign out from Firebase Auth
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;

  // Get user email
  String? get userEmail => _auth.currentUser?.email;

  // Get user profile data from Firestore
  Future<Map<String, dynamic>?> getUserProfileData() async {
    try {
      return await FirestoreService.getCurrentUserProfile();
    } catch (e) {
      throw 'Failed to get user profile data';
    }
  }

  // Get user profile stream for real-time updates
  Stream<Map<String, dynamic>?> getUserProfileStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return FirestoreService.streamUserProfile(currentUser.uid).map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? status,
    String? bio,
  }) async {
    try {
      // Update Firebase Auth profile
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }

      // Update Firestore profile
      await FirestoreService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
        status: status,
        bio: bio,
      );
    } catch (e) {
      throw 'Failed to update profile';
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account';
    }
  }
}
