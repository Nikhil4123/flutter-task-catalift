import 'package:catalift/models/course_model.dart';
import 'package:catalift/models/post_model.dart';
import 'package:catalift/models/user_model.dart';
import 'package:catalift/services/firestore_service.dart';
import 'package:catalift/services/mock_data_service.dart';

/// ServiceProvider acts as a facade for data operations,
/// allowing the app to switch between mock data and Firebase
class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._internal();
  factory ServiceProvider() => _instance;
  ServiceProvider._internal();

  // Dependencies
  final FirestoreService _firestoreService = FirestoreService();
  final MockDataService _mockDataService = MockDataService();

  // Configuration
  bool _useMockData = true;

  // Setter to change data source at runtime
  set useMockData(bool value) {
    _useMockData = value;
  }

  // Getter to check current data source
  bool get useMockData => _useMockData;

  // User Methods
  Future<UserModel?> getUserById(String userId) async {
    if (_useMockData) {
      return Future.value(_mockDataService.getUserById(userId));
    } else {
      return _firestoreService.getUserById(userId);
    }
  }

  Future<UserModel?> getCurrentUser(String? userId) async {
    if (_useMockData) {
      if (userId == null) return null;
      return Future.value(_mockDataService.getUserById(userId));
    } else {
      return _firestoreService.getCurrentUser();
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    if (_useMockData) {
      // For mock data, we currently don't have update functionality
      // This could be added to the MockDataService if needed
      return Future.value();
    } else {
      return _firestoreService.updateUserProfile(user);
    }
  }

  Future<void> followUser(String userId, String targetUserId) async {
    if (_useMockData) {
      // MockDataService doesn't have this functionality yet
      return Future.value();
    } else {
      return _firestoreService.followUser(userId, targetUserId);
    }
  }

  Future<void> unfollowUser(String userId, String targetUserId) async {
    if (_useMockData) {
      // MockDataService doesn't have this functionality yet
      return Future.value();
    } else {
      return _firestoreService.unfollowUser(userId, targetUserId);
    }
  }

  Future<List<UserModel>> getMentors() async {
    if (_useMockData) {
      return Future.value(_mockDataService.users.where((user) => user.userType == 'mentor').toList());
    } else {
      return _firestoreService.getMentors();
    }
  }

  // Posts Methods
  Future<List<PostModel>> getPosts() async {
    if (_useMockData) {
      return Future.value(_mockDataService.posts);
    } else {
      return _firestoreService.getPosts();
    }
  }

  Future<List<PostModel>> getPostsByUser(String userId) async {
    if (_useMockData) {
      return Future.value(_mockDataService.getPostsByUser(userId));
    } else {
      return _firestoreService.getPostsByUser(userId);
    }
  }

  Future<void> addPost(PostModel post) async {
    if (_useMockData) {
      _mockDataService.addPost(post);
      return Future.value();
    } else {
      return _firestoreService.addPost(post);
    }
  }

  Future<void> likePost(String postId, String userId) async {
    if (_useMockData) {
      _mockDataService.likePost(postId, userId);
      return Future.value();
    } else {
      return _firestoreService.likePost(postId, userId);
    }
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    if (_useMockData) {
      _mockDataService.addComment(postId, comment);
      return Future.value();
    } else {
      return _firestoreService.addComment(postId, comment);
    }
  }

  // Courses Methods
  Future<List<CourseModel>> getCourses() async {
    if (_useMockData) {
      return Future.value(_mockDataService.courses);
    } else {
      return _firestoreService.getCourses();
    }
  }

  Future<List<CourseModel>> getCoursesByMentor(String mentorId) async {
    if (_useMockData) {
      return Future.value(_mockDataService.getCoursesByMentor(mentorId));
    } else {
      return _firestoreService.getCoursesByMentor(mentorId);
    }
  }

  Future<List<CourseModel>> getEnrolledCourses(String studentId) async {
    if (_useMockData) {
      return Future.value(_mockDataService.getEnrolledCourses(studentId));
    } else {
      return _firestoreService.getEnrolledCourses(studentId);
    }
  }

  Future<void> addCourse(CourseModel course) async {
    if (_useMockData) {
      _mockDataService.addCourse(course);
      return Future.value();
    } else {
      return _firestoreService.addCourse(course);
    }
  }

  Future<void> enrollInCourse(String courseId, String studentId) async {
    if (_useMockData) {
      _mockDataService.enrollInCourse(courseId, studentId);
      return Future.value();
    } else {
      return _firestoreService.enrollInCourse(courseId, studentId);
    }
  }

  // Search Methods
  Future<List<PostModel>> searchPosts(String query) async {
    if (_useMockData) {
      return Future.value(_mockDataService.searchPosts(query));
    } else {
      return _firestoreService.searchPosts(query);
    }
  }

  Future<List<CourseModel>> searchCourses(String query) async {
    if (_useMockData) {
      return Future.value(_mockDataService.searchCourses(query));
    } else {
      return _firestoreService.searchCourses(query);
    }
  }
} 