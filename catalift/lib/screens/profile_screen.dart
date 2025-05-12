import 'dart:io';

import 'package:catalift/models/user_model.dart';
import 'package:catalift/services/auth_service.dart';
import 'package:catalift/services/service_provider.dart';
import 'package:catalift/services/storage_service.dart';
import 'package:catalift/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // If null, show current user's profile

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ServiceProvider _serviceProvider = ServiceProvider();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  late Future<UserModel?> _userFuture;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImage;
  UserModel? _currentUser;
  
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    if (widget.userId != null) {
      _userFuture = _serviceProvider.getUserById(widget.userId!);
      // If showing someone else's profile, don't enable editing
      _isEditing = false;
    } else {
      // Get current logged in user
      final String? currentUserId = AuthService().currentUser?.id;
      _userFuture = _serviceProvider.getCurrentUser(currentUserId);
      // Allow editing own profile
      _isEditing = false;
      
      // Pre-populate fields when the user is loaded
      _userFuture.then((user) {
        if (user != null) {
          _currentUser = user;
          _nameController.text = user.name;
          _bioController.text = user.bio ?? '';
          _roleController.text = user.role ?? '';
        }
      });
    }
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
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      String? profileImageUrl = _currentUser!.profileImage;
      
      // Upload new profile image if selected
      if (_profileImage != null) {
        profileImageUrl = await _storageService.uploadProfileImage(
          _profileImage!, 
          _currentUser!.id
        );
      }
      
      // Create updated user data
      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text,
        bio: _bioController.text,
        role: _roleController.text,
        profileImage: profileImageUrl,
      );
      
      // Update user in the service
      await _serviceProvider.updateUserProfile(updatedUser);
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      
      // Refresh user data
      _loadUser();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Only show edit button on own profile
          if (widget.userId == null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    // Reset form when canceling edit
                    if (_currentUser != null) {
                      _nameController.text = _currentUser!.name;
                      _bioController.text = _currentUser!.bio ?? '';
                      _roleController.text = _currentUser!.role ?? '';
                    }
                  }
                });
              },
            ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _profileImage != null 
                            ? FileImage(_profileImage!) 
                            : (user.profileImage != null 
                                ? NetworkImage(user.profileImage!) 
                                : null) as ImageProvider?,
                        child: user.profileImage == null && _profileImage == null
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 40),
                              )
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppConstants.primaryColor,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Profile Information
                if (_isEditing) ...[
                  // Editable fields
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role/Position',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Save Profile'),
                    ),
                  ),
                ] else ...[
                  // Read-only profile display
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user.role != null && user.role!.isNotEmpty)
                    Text(
                      user.role!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.bio!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(user.followers.length.toString(), 'Followers'),
                      _buildStatColumn(user.following.length.toString(), 'Following'),
                      if (user.userType == 'mentor')
                        _buildStatColumn('4.8', 'Rating'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Mentor specific info
                  if (user.userType == 'mentor') ...[
                    const Text(
                      'Courses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<dynamic>>(
                      future: _serviceProvider.getCoursesByMentor(user.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final courses = snapshot.data ?? [];
                        
                        if (courses.isEmpty) {
                          return const Text('No courses available');
                        }
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return ListTile(
                              title: Text(course.title),
                              subtitle: Text(course.difficulty),
                              trailing: Text('${course.enrolledStudents.length} enrolled'),
                            );
                          },
                        );
                      },
                    ),
                  ],
                  
                  // Follow button for other users' profiles
                  if (widget.userId != null) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          // Follow/unfollow functionality will be implemented here
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppConstants.primaryColor),
                        ),
                        child: const Text('Follow'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
} 