class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userRole;
  final String? userProfileImage;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<String> likes;
  final int commentsCount;
  final List<CommentModel> comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userRole,
    this.userProfileImage,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.editedAt,
    this.likes = const [],
    this.commentsCount = 0,
    this.comments = const [],
  });

  // Create a copy with some changes
  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? userProfileImage,
    String? title,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? editedAt,
    List<String>? likes,
    int? commentsCount,
    List<CommentModel>? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      comments: comments ?? this.comments,
    );
  }

  // Convert post to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'userProfileImage': userProfileImage,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'editedAt': editedAt?.millisecondsSinceEpoch,
      'likes': likes,
      'commentsCount': commentsCount,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }

  // Create post from map
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userRole: map['userRole'],
      userProfileImage: map['userProfileImage'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      editedAt: map['editedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['editedAt']) : null,
      likes: List<String>.from(map['likes'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      comments: List<CommentModel>.from(
        (map['comments'] ?? []).map((comment) => CommentModel.fromMap(comment)),
      ),
    );
  }
}

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String content;
  final DateTime createdAt;
  final List<String> likes;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.content,
    required this.createdAt,
    this.likes = const [],
  });

  // Create a copy with some changes
  CommentModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? content,
    DateTime? createdAt,
    List<String>? likes,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
    );
  }

  // Convert comment to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'likes': likes,
    };
  }

  // Create comment from map
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImage: map['userProfileImage'],
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }
} 