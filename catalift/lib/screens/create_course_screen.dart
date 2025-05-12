import 'dart:io';

import 'package:catalift/models/course_model.dart';
import 'package:catalift/models/user_model.dart';
import 'package:catalift/services/auth_service.dart';
import 'package:catalift/services/firestore_service.dart';
import 'package:catalift/services/storage_service.dart';
import 'package:catalift/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({Key? key}) : super(key: key);

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final List<String> _topics = [];
  
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  String _difficulty = 'beginner'; // Default difficulty
  bool _isLoading = false;
  String? _errorMessage;
  File? _courseImage;
  String? _courseImageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _addTopic() {
    if (_topicController.text.isNotEmpty) {
      setState(() {
        _topics.add(_topicController.text.trim());
        _topicController.clear();
      });
    }
  }

  void _removeTopic(int index) {
    setState(() {
      _topics.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _courseImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _errorMessage = 'Failed to pick image. Please try again.';
      });
    }
  }

  Future<void> _createCourse() async {
    // Validate inputs
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Title and description are required';
      });
      return;
    }

    if (_topics.isEmpty) {
      setState(() {
        _errorMessage = 'Add at least one topic for your course';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final UserModel? currentUser = await _firestoreService.getCurrentUser();
      if (currentUser == null || currentUser.userType != 'mentor') {
        setState(() {
          _errorMessage = 'Only mentors can create courses';
          _isLoading = false;
        });
        return;
      }

      // Upload image if selected
      if (_courseImage != null) {
        _courseImageUrl = await _storageService.uploadCourseImage(_courseImage!);
      }

      // Create a new course with current user as mentor
      final newCourse = CourseModel(
        id: 'temp_id', // Will be replaced by Firestore
        mentorId: currentUser.id,
        mentorName: currentUser.name,
        mentorProfileImage: currentUser.profileImage,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _courseImageUrl,
        topics: _topics,
        difficulty: _difficulty,
        createdAt: DateTime.now(),
        enrolledStudents: [],
        rating: 0.0,
        reviewCount: 0,
      );

      // Add the course to Firestore
      await _firestoreService.addCourse(newCourse);

      // Show success message and navigate back
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating course: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              
              // Course Image Selector
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    image: _courseImage != null
                        ? DecorationImage(
                            image: FileImage(_courseImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _courseImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Course Image',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Course Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  hintText: 'Enter a descriptive title for your course',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Course Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Course Description',
                  hintText: 'Provide a detailed description of what students will learn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              // Course Topics
              const Text(
                'Course Topics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        hintText: 'Add a topic (e.g., Flutter Basics)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: AppConstants.primaryColor,
                    onPressed: _addTopic,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_topics.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      _topics.length,
                      (index) => Chip(
                        label: Text(_topics[index]),
                        deleteIcon: const Icon(Icons.cancel, size: 18),
                        onDeleted: () => _removeTopic(index),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Course Difficulty
              const Text(
                'Course Difficulty',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'beginner',
                    child: Text('Beginner'),
                  ),
                  DropdownMenuItem(
                    value: 'intermediate',
                    child: Text('Intermediate'),
                  ),
                  DropdownMenuItem(
                    value: 'advanced',
                    child: Text('Advanced'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // Create Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Course',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 