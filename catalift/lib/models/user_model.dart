class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? bio;
  final String? role;
  final List<String> followers;
  final List<String> following;
  final String userType; // mentor or student

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.bio,
    this.role,
    this.followers = const [],
    this.following = const [],
    this.userType = 'student', // default is student
  });

  // For creating a copy of the user with some changes
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? bio,
    String? role,
    List<String>? followers,
    List<String>? following,
    String? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      userType: userType ?? this.userType,
    );
  }

  // Convert user object to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'role': role,
      'followers': followers,
      'following': following,
      'userType': userType,
    };
  }

  // Create a user from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      bio: map['bio'],
      role: map['role'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      userType: map['userType'] ?? 'student',
    );
  }
} 