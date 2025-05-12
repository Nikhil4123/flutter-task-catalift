import 'package:catalift/models/course_model.dart';
import 'package:catalift/models/user_model.dart';
import 'package:catalift/screens/create_course_screen.dart';
import 'package:catalift/services/auth_service.dart';
import 'package:catalift/services/firestore_service.dart';
import 'package:catalift/utils/app_constants.dart';
import 'package:flutter/material.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _difficultyFilter = 'all'; // 'all', 'beginner', 'intermediate', 'advanced'
  bool _enrolledOnly = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserModel? currentUser = await _firestoreService.getCurrentUser();
      List<CourseModel> coursesToDisplay = [];

      if (_searchQuery.isNotEmpty) {
        coursesToDisplay = await _firestoreService.searchCourses(_searchQuery);
      } else {
        coursesToDisplay = await _firestoreService.getCourses();
      }

      // Apply difficulty filter
      if (_difficultyFilter != 'all') {
        coursesToDisplay = coursesToDisplay.where(
          (course) => course.difficulty == _difficultyFilter
        ).toList();
      }

      // Filter for enrolled courses if user is a student
      if (_enrolledOnly && currentUser != null && currentUser.userType == 'student') {
        final enrolledCourses = await _firestoreService.getEnrolledCourses(currentUser.id);
        final enrolledIds = enrolledCourses.map((c) => c.id).toSet();
        coursesToDisplay = coursesToDisplay.where(
          (course) => enrolledIds.contains(course.id)
        ).toList();
      }
      
      setState(() {
        _courses = coursesToDisplay;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadCourses();
  }

  void _handleCreateCourse() async {
    final UserModel? currentUser = await _firestoreService.getCurrentUser();
    if (currentUser != null && currentUser.userType == 'mentor') {
      if (!mounted) return;
      
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => const CreateCourseScreen(),
        ),
      ).then((_) => _loadCourses()); // Reload courses when returning
    } else {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only mentors can create courses')),
      );
    }
  }

  void _handleEnroll(CourseModel course) async {
    try {
      final UserModel? currentUser = await _firestoreService.getCurrentUser();
      if (currentUser != null && currentUser.userType == 'student') {
        if (!course.enrolledStudents.contains(currentUser.id)) {
          await _firestoreService.enrollInCourse(course.id, currentUser.id);
          await _loadCourses();
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enrolled in ${course.title}')),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are already enrolled in this course')),
          );
        }
      } else if (currentUser?.userType == 'mentor') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mentors cannot enroll in courses')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to enroll in courses')),
        );
      }
    } catch (e) {
      print('Error enrolling in course: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to enroll in course. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child: _buildCoursesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateCourse,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppConstants.primaryColor,
      child: const Row(
        children: [
          Text(
            'Courses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search courses',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 10),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _handleSearch('');
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return FutureBuilder<UserModel?>(
      future: _firestoreService.getCurrentUser(),
      builder: (context, snapshot) {
        final UserModel? currentUser = snapshot.data;
        final bool isStudent = currentUser?.userType == 'student';
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _difficultyFilter,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          hint: const Text('Difficulty'),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Levels'),
                            ),
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
                              _difficultyFilter = value!;
                            });
                            _loadCourses();
                          },
                        ),
                      ),
                    ),
                  ),
                  if (isStudent) ...[
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('My Courses'),
                      selected: _enrolledOnly,
                      onSelected: (selected) {
                        setState(() {
                          _enrolledOnly = selected;
                        });
                        _loadCourses();
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppConstants.primaryColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildCoursesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No courses available'
                  : 'No results found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          return _buildCourseCard(_courses[index]);
        },
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return FutureBuilder<UserModel?>(
      future: _firestoreService.getCurrentUser(),
      builder: (context, snapshot) {
        final UserModel? currentUser = snapshot.data;
        final bool isEnrolled = currentUser != null && 
                              course.enrolledStudents.contains(currentUser.id);
        final bool isMentor = currentUser?.id == course.mentorId;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(course.difficulty),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _capitalize(course.difficulty),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: course.mentorProfileImage != null
                              ? NetworkImage(course.mentorProfileImage!)
                              : null,
                          child: course.mentorProfileImage == null
                              ? Text(course.mentorName[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          course.mentorName,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${course.reviewCount})',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: course.topics.map((topic) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            topic,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.enrolledStudents.length} enrolled',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (currentUser?.userType == 'student' && !isEnrolled)
                      ElevatedButton(
                        onPressed: () => _handleEnroll(course),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Enroll'),
                      )
                    else if (isEnrolled)
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Enrolled'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    else if (isMentor)
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Manage'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
} 