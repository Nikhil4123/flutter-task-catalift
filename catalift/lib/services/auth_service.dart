import 'package:catalift/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Check if current user is a mentor
  bool get isMentor => _currentUser?.userType == 'mentor';
  
  // Initialize current user from Firebase
  Future<void> initCurrentUser() async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        _currentUser = UserModel.fromMap({
          'id': firebaseUser.uid,
          ...userDoc.data()!,
        });
      }
    }
  }

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _currentUser = UserModel.fromMap({
            'id': user.uid,
            ...userDoc.data()!,
          });
          return _currentUser;
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Register new user
  Future<UserModel?> register(String name, String email, String password, String userType) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      if (user != null) {
        // Create user data in Firestore
        final newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
          userType: userType,
          followers: [],
          following: [],
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        
        _currentUser = newUser;
        return newUser;
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }
} 