import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;

  // Google Sign In
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // The user canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Save user profile info in Firestore upon login
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'displayName': userCredential.user!.displayName ?? 'Anonymous User',
          'photoURL': userCredential.user!.photoURL ?? '',
          'email': userCredential.user!.email ?? '',
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      return userCredential;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  // Anonymous Sign In (Guest)
  static Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        // Only set default profile if it doesn't exist yet
        final docSnap = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (!docSnap.exists) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'displayName': 'Guest User',
            'photoURL': '',
            'email': '',
            'isAnonymous': true,
            'lastActive': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'lastActive': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
      return userCredential;
    } catch (e) {
      print("Error signing in anonymously: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Progress Tracking: Save learned vocabulary
  static Future<void> toggleVocabLearned(String category, String word, bool isLearned) async {
    if (currentUser == null) return;
    
    final docRef = _firestore.collection('users').doc(currentUser!.uid).collection('vocab_progress').doc(category);
    
    if (isLearned) {
      await docRef.set({
        'learnedWords': FieldValue.arrayUnion([word])
      }, SetOptions(merge: true));
    } else {
      await docRef.set({
        'learnedWords': FieldValue.arrayRemove([word])
      }, SetOptions(merge: true));
    }
  }

  static Future<List<String>> getLearnedVocab(String category) async {
    if (currentUser == null) return [];
    
    final docSnap = await _firestore.collection('users').doc(currentUser!.uid).collection('vocab_progress').doc(category).get();
    
    if (docSnap.exists) {
      final data = docSnap.data();
      if (data != null && data['learnedWords'] != null) {
        return List<String>.from(data['learnedWords']);
      }
    }
    return [];
  }

  // Quiz Score tracking
  static Future<void> saveQuizScore(int score) async {
    if (currentUser == null) return;

    final userRef = _firestore.collection('users').doc(currentUser!.uid);
    
    await userRef.set({
      'totalScore': FieldValue.increment(score),
    }, SetOptions(merge: true));
  }

  // Get Leaderboard
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final snapshot = await _firestore.collection('users').orderBy('totalScore', descending: true).limit(50).get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
