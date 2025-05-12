class CourseModel {
  final String id;
  final String mentorId;
  final String mentorName;
  final String? mentorProfileImage;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> topics;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> enrolledStudents;
  final double rating;
  final int reviewCount;

  CourseModel({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    this.mentorProfileImage,
    required this.title,
    required this.description,
    this.imageUrl,
    this.topics = const [],
    this.difficulty = 'beginner',
    required this.createdAt,
    this.updatedAt,
    this.enrolledStudents = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  // Create a copy with some changes
  CourseModel copyWith({
    String? id,
    String? mentorId,
    String? mentorName,
    String? mentorProfileImage,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? topics,
    String? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? enrolledStudents,
    double? rating,
    int? reviewCount,
  }) {
    return CourseModel(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      mentorProfileImage: mentorProfileImage ?? this.mentorProfileImage,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      topics: topics ?? this.topics,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  // Convert course to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'mentorProfileImage': mentorProfileImage,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'topics': topics,
      'difficulty': difficulty,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'enrolledStudents': enrolledStudents,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  // Create course from map
  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? '',
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      mentorProfileImage: map['mentorProfileImage'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      topics: List<String>.from(map['topics'] ?? []),
      difficulty: map['difficulty'] ?? 'beginner',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) : null,
      enrolledStudents: List<String>.from(map['enrolledStudents'] ?? []),
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] ?? 0,
    );
  }
} 