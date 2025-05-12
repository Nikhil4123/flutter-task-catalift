import 'package:catalift/models/course_model.dart';
import 'package:catalift/models/post_model.dart';
import 'package:catalift/models/user_model.dart';

class MockDataService {
  // Static users
  static final List<UserModel> _users = [
    UserModel(
      id: 'user1',
      name: 'Akhilesh Yadav',
      email: 'akhilesh@example.com',
      role: 'Founder at Google',
      profileImage: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3',
      followers: ['user2', 'user3'],
      following: ['user2'],
      userType: 'mentor',
    ),
    UserModel(
      id: 'user2',
      name: 'Priya Sharma',
      email: 'priya@example.com',
      role: 'Science Educator',
      profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      followers: ['user1'],
      following: ['user1', 'user3'],
      userType: 'mentor',
    ),
    UserModel(
      id: 'user3',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'Senior Developer',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      followers: ['user2'],
      following: ['user1'],
      userType: 'student',
    ),
  ];

  // Static posts
  static final List<PostModel> _posts = [
    PostModel(
      id: 'post1',
      userId: 'user1',
      userName: 'Akhilesh Yadav',
      userRole: 'Founder at Google',
      userProfileImage: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3',
      title: 'The Briggs-Rauscher Reaction: A Mesmerizing Chemical Dance 🌈',
      content: 'This captivating process uses hydrogen peroxide, potassium iodate, malonic acid, manganese sulfate, and starch.\n\nIodine and iodate ions interact to form compounds that shift the solution\'s color, while starch amplifies the blue color before it breaks down and starts again. ✨',
      imageUrl: 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      editedAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: ['user2', 'user3'],
      commentsCount: 2,
      comments: [
        CommentModel(
          id: 'comment1',
          userId: 'user2',
          userName: 'Priya Sharma',
          userProfileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
          content: 'This is truly fascinating! Thanks for sharing.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          likes: ['user1'],
        ),
        CommentModel(
          id: 'comment2',
          userId: 'user3',
          userName: 'John Doe',
          userProfileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
          content: 'I remember seeing this in my chemistry class. Amazing phenomenon!',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    ),
    PostModel(
      id: 'post2',
      userId: 'user2',
      userName: 'Priya Sharma',
      userRole: 'Science Educator',
      userProfileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      title: 'The Wonder of Quantum Entanglement 🔬',
      content: 'Einstein called it "spooky action at a distance." Quantum entanglement occurs when pairs of particles interact in ways such that the quantum state of each particle cannot be described independently of the others.\n\nThis fascinating phenomenon is the basis for quantum computing and may revolutionize our technology!',
      imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likes: ['user1'],
      commentsCount: 1,
      comments: [
        CommentModel(
          id: 'comment3',
          userId: 'user1',
          userName: 'Akhilesh Yadav',
          userProfileImage: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3',
          content: 'Great explanation of this complex concept!',
          createdAt: DateTime.now().subtract(const Duration(hours: 10)),
          likes: ['user2'],
        ),
      ],
    ),
    PostModel(
      id: 'post3',
      userId: 'user3',
      userName: 'John Doe',
      userRole: 'Senior Developer',
      userProfileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      title: 'Flutter vs React Native: A Developer\'s Perspective 💻',
      content: 'After working with both frameworks extensively, I believe Flutter offers more consistent performance and a more enjoyable development experience.\n\nReact Native has its strengths in the massive npm ecosystem, but Flutter\'s widget system and hot reload functionality make development smoother.',
      imageUrl: 'https://images.unsplash.com/photo-1551650975-87deedd944c3?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likes: ['user1', 'user2'],
      commentsCount: 2,
      comments: [
        CommentModel(
          id: 'comment4',
          userId: 'user1',
          userName: 'Akhilesh Yadav',
          userProfileImage: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3',
          content: 'Interesting comparison! What about performance on iOS?',
          createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        ),
        CommentModel(
          id: 'comment5',
          userId: 'user2',
          userName: 'Priya Sharma',
          userProfileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
          content: 'I\'ve been thinking of learning Flutter. This post convinced me!',
          createdAt: DateTime.now().subtract(const Duration(hours: 15)),
          likes: ['user3'],
        ),
      ],
    ),
  ];

  // Static courses
  static final List<CourseModel> _courses = [
    CourseModel(
      id: 'course1',
      mentorId: 'user1',
      mentorName: 'Akhilesh Yadav',
      mentorProfileImage: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3',
      title: 'Introduction to Quantum Computing',
      description: 'Learn the basics of quantum computing, from qubits to quantum gates and circuits. This course is designed for beginners with a basic understanding of linear algebra.',
      imageUrl: 'https://images.unsplash.com/photo-1639507986194-48ef61eaeda2?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3',
      topics: ['Quantum Mechanics', 'Qubits', 'Quantum Gates', 'Quantum Algorithms'],
      difficulty: 'beginner',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      enrolledStudents: ['user3'],
      rating: 4.8,
      reviewCount: 24,
    ),
    CourseModel(
      id: 'course2',
      mentorId: 'user2',
      mentorName: 'Priya Sharma',
      mentorProfileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      title: 'Advanced Chemistry Concepts',
      description: 'Explore advanced chemistry topics including organic reactions, spectroscopy, and computational chemistry. This course is designed for students with a strong background in basic chemistry.',
      imageUrl: 'https://images.unsplash.com/photo-1616334761731-80dfa0a34333?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      topics: ['Organic Chemistry', 'Spectroscopy', 'Reaction Mechanisms', 'Computational Chemistry'],
      difficulty: 'advanced',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      enrolledStudents: [],
      rating: 4.6,
      reviewCount: 18,
    ),
    CourseModel(
      id: 'course3',
      mentorId: 'user1',
      mentorName: 'Akhilesh Yadav',
      mentorProfileImage: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3',
      title: 'Flutter Mobile Development Masterclass',
      description: 'Build beautiful, natively compiled applications for mobile from a single codebase with Flutter. This course covers everything from basic widgets to advanced state management.',
      imageUrl: 'https://images.unsplash.com/photo-1581276879432-15e50529f34b?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3',
      topics: ['Flutter', 'Dart', 'Mobile Development', 'UI Design', 'State Management'],
      difficulty: 'intermediate',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      enrolledStudents: ['user3'],
      rating: 4.9,
      reviewCount: 32,
    ),
  ];

  // Singleton instance
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Methods to access mock data
  List<UserModel> get users => List.from(_users);
  List<PostModel> get posts => List.from(_posts);
  List<CourseModel> get courses => List.from(_courses);

  // Get user by ID
  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get user by email (for login)
  UserModel? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Get posts by user
  List<PostModel> getPostsByUser(String userId) {
    return _posts.where((post) => post.userId == userId).toList();
  }

  // Get courses by mentor
  List<CourseModel> getCoursesByMentor(String mentorId) {
    return _courses.where((course) => course.mentorId == mentorId).toList();
  }

  // Get enrolled courses for a student
  List<CourseModel> getEnrolledCourses(String studentId) {
    return _courses.where((course) => 
      course.enrolledStudents.contains(studentId)
    ).toList();
  }

  // Enroll in a course
  void enrollInCourse(String courseId, String studentId) {
    final courseIndex = _courses.indexWhere((course) => course.id == courseId);
    if (courseIndex != -1) {
      final course = _courses[courseIndex];
      if (!course.enrolledStudents.contains(studentId)) {
        _courses[courseIndex] = course.copyWith(
          enrolledStudents: List.from(course.enrolledStudents)..add(studentId),
        );
      }
    }
  }

  // Add a new course
  void addCourse(CourseModel course) {
    _courses.insert(0, course);
  }

  // Like a post
  void likePost(String postId, String userId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      if (post.likes.contains(userId)) {
        // Unlike if already liked
        _posts[postIndex] = post.copyWith(
          likes: List.from(post.likes)..remove(userId),
        );
      } else {
        // Like if not already liked
        _posts[postIndex] = post.copyWith(
          likes: List.from(post.likes)..add(userId),
        );
      }
    }
  }

  // Add a comment to a post
  void addComment(String postId, CommentModel comment) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = post.copyWith(
        comments: List.from(post.comments)..add(comment),
        commentsCount: post.commentsCount + 1,
      );
    }
  }

  // Search posts
  List<PostModel> searchPosts(String query) {
    if (query.isEmpty) return _posts;
    
    query = query.toLowerCase();
    return _posts.where((post) {
      return post.title.toLowerCase().contains(query) || 
             post.content.toLowerCase().contains(query) ||
             post.userName.toLowerCase().contains(query);
    }).toList();
  }

  // Search courses
  List<CourseModel> searchCourses(String query) {
    if (query.isEmpty) return _courses;
    
    query = query.toLowerCase();
    return _courses.where((course) {
      return course.title.toLowerCase().contains(query) || 
             course.description.toLowerCase().contains(query) ||
             course.topics.any((topic) => topic.toLowerCase().contains(query)) ||
             course.mentorName.toLowerCase().contains(query);
    }).toList();
  }

  // Add a new post
  void addPost(PostModel post) {
    _posts.insert(0, post); // Add to beginning of list
  }
} 