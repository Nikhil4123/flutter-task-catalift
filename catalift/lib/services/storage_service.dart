import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference reference = _storage.ref().child('profile_images/$fileName');
      
      final UploadTask uploadTask = reference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload post image
  Future<String?> uploadPostImage(File imageFile) async {
    try {
      final String fileName = 'post_${_uuid.v4()}.jpg';
      final Reference reference = _storage.ref().child('post_images/$fileName');
      
      final UploadTask uploadTask = reference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading post image: $e');
      return null;
    }
  }

  // Upload course image
  Future<String?> uploadCourseImage(File imageFile) async {
    try {
      final String fileName = 'course_${_uuid.v4()}.jpg';
      final Reference reference = _storage.ref().child('course_images/$fileName');
      
      final UploadTask uploadTask = reference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading course image: $e');
      return null;
    }
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference reference = _storage.refFromURL(imageUrl);
      await reference.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
} 