import 'package:flutter/material.dart';

class AppConstants {
  // App colors
  static const Color primaryColor = Color(0xFF070658);
  static const Color secondaryColor = Colors.white;
  static const Color accentColor = Color(0xFFFFD700); // Gold

  // Text styles
  static const TextStyle appBarTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle postTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle postContent = TextStyle(
    fontSize: 14,
  );

  static const TextStyle userName = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle userRole = TextStyle(
    color: Colors.grey,
    fontSize: 13,
  );

  // Padding and spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // App routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String createPostRoute = '/create-post';
  
  // App messages
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Login failed. Please check your credentials';
  static const String registerSuccess = 'Registration successful';
  static const String registerFailed = 'Registration failed. Email may already be in use';
  static const String logoutConfirm = 'Are you sure you want to logout?';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
} 