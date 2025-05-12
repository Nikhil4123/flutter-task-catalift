import 'package:catalift/models/course_model.dart';
import 'package:catalift/models/post_model.dart';
import 'package:catalift/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Methods
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return getUserById(user.uid);
    }
    return null;
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> followUser(String userId, String targetUserId) async {
    try {
      // Add targetUserId to current user's following list
      await _firestore.collection('users').doc(userId).update({
        'following': FieldValue.arrayUnion([targetUserId]),
      });
      
      // Add current userId to target user's followers list
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error following user: $e');
      throw Exception('Failed to follow user: $e');
    }
  }

  Future<void> unfollowUser(String userId, String targetUserId) async {
    try {
      // Remove targetUserId from current user's following list
      await _firestore.collection('users').doc(userId).update({
        'following': FieldValue.arrayRemove([targetUserId]),
      });
      
      // Remove current userId from target user's followers list
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error unfollowing user: $e');
      throw Exception('Failed to unfollow user: $e');
    }
  }

  Future<List<UserModel>> getMentors() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'mentor')
          .get();

      return snapshot.docs.map((doc) {
        return UserModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting mentors: $e');
      return [];
    }
  }

  // Posts Methods
  Future<List<PostModel>> getPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return PostModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }

  Future<List<PostModel>> getPostsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return PostModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }

  Future<void> addPost(PostModel post) async {
    try {
      Map<String, dynamic> postData = post.toMap();
      // Remove ID as Firestore will generate one
      postData.remove('id');
      
      // Convert DateTime to Timestamp
      postData['createdAt'] = Timestamp.fromDate(post.createdAt);
      if (post.editedAt != null) {
        postData['editedAt'] = Timestamp.fromDate(post.editedAt!);
      }
      
      await _firestore.collection('posts').add(postData);
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final post = await postRef.get();
      
      if (post.exists) {
        List<dynamic> likes = post.data()?['likes'] ?? [];
        
        if (likes.contains(userId)) {
          // Unlike
          await postRef.update({
            'likes': FieldValue.arrayRemove([userId]),
          });
        } else {
          // Like
          await postRef.update({
            'likes': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      Map<String, dynamic> commentData = comment.toMap();
      
      // Convert DateTime to Timestamp
      commentData['createdAt'] = Timestamp.fromDate(comment.createdAt);
      
      await postRef.update({
        'comments': FieldValue.arrayUnion([commentData]),
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  // Courses Methods
  Future<List<CourseModel>> getCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return CourseModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  Future<List<CourseModel>> getCoursesByMentor(String mentorId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('mentorId', isEqualTo: mentorId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return CourseModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting mentor courses: $e');
      return [];
    }
  }

  Future<List<CourseModel>> getEnrolledCourses(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('enrolledStudents', arrayContains: studentId)
          .get();

      return snapshot.docs.map((doc) {
        return CourseModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting enrolled courses: $e');
      return [];
    }
  }

  Future<void> addCourse(CourseModel course) async {
    try {
      Map<String, dynamic> courseData = course.toMap();
      // Remove ID as Firestore will generate one
      courseData.remove('id');
      
      // Convert DateTime to Timestamp
      courseData['createdAt'] = Timestamp.fromDate(course.createdAt);
      if (course.updatedAt != null) {
        courseData['updatedAt'] = Timestamp.fromDate(course.updatedAt!);
      }
      
      await _firestore.collection('courses').add(courseData);
    } catch (e) {
      print('Error adding course: $e');
    }
  }

  Future<void> enrollInCourse(String courseId, String studentId) async {
    try {
      final courseRef = _firestore.collection('courses').doc(courseId);
      
      await courseRef.update({
        'enrolledStudents': FieldValue.arrayUnion([studentId]),
      });
    } catch (e) {
      print('Error enrolling in course: $e');
    }
  }

  // Search Methods
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      // Firestore doesn't have native text search, so we're implementing a simple contains check
      // In a production app, you would use Algolia or a similar service for full-text search
      final snapshot = await _firestore.collection('posts').get();
      
      final searchResults = snapshot.docs.where((doc) {
        final data = doc.data();
        final title = data['title']?.toString().toLowerCase() ?? '';
        final content = data['content']?.toString().toLowerCase() ?? '';
        final userName = data['userName']?.toString().toLowerCase() ?? '';
        
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || 
               content.contains(searchQuery) || 
               userName.contains(searchQuery);
      }).map((doc) {
        return PostModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
      
      return searchResults;
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }

  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      // Simple search implementation
      final snapshot = await _firestore.collection('courses').get();
      
      final searchResults = snapshot.docs.where((doc) {
        final data = doc.data();
        final title = data['title']?.toString().toLowerCase() ?? '';
        final description = data['description']?.toString().toLowerCase() ?? '';
        final mentorName = data['mentorName']?.toString().toLowerCase() ?? '';
        final topics = (data['topics'] as List<dynamic>?)?.map((t) => t.toString().toLowerCase()).toList() ?? [];
        
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || 
               description.contains(searchQuery) || 
               mentorName.contains(searchQuery) ||
               topics.any((topic) => topic.contains(searchQuery));
      }).map((doc) {
        return CourseModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
      
      return searchResults;
    } catch (e) {
      print('Error searching courses: $e');
      return [];
    }
  }
} 