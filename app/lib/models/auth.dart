import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final googleSignIn = GoogleSignIn();

  static User? get currentUser => firebaseAuth.currentUser;

  static Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  static Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
