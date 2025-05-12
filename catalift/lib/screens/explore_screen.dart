import 'package:catalift/models/user_model.dart';
import 'package:catalift/screens/profile_screen.dart';
import 'package:catalift/services/service_provider.dart';
import 'package:catalift/utils/app_constants.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ServiceProvider _serviceProvider = ServiceProvider();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> _mentors = [];
  List<UserModel> _filteredMentors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMentors() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final mentors = await _serviceProvider.getMentors();
      setState(() {
        _mentors = mentors;
        _filteredMentors = mentors;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading mentors: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterMentors(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMentors = _mentors;
      });
      return;
    }
    
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredMentors = _mentors.where((mentor) {
        return mentor.name.toLowerCase().contains(lowercaseQuery) || 
               (mentor.role?.toLowerCase().contains(lowercaseQuery) ?? false) ||
               (mentor.bio?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Mentors'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMentors,
              decoration: InputDecoration(
                hintText: 'Search mentors...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Mentors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMentors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No mentors available'
                                  : 'No mentors found matching "${_searchController.text}"',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredMentors.length,
                        itemBuilder: (context, index) {
                          final mentor = _filteredMentors[index];
                          return _buildMentorCard(mentor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(UserModel mentor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: mentor.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: mentor.profileImage != null
                    ? NetworkImage(mentor.profileImage!)
                    : null,
                child: mentor.profileImage == null
                    ? Text(
                        mentor.name.isNotEmpty
                            ? mentor.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Mentor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mentor.role != null && mentor.role!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        mentor.role!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '4.8', // Placeholder - would come from actual rating
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${mentor.followers.length} followers',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Follow Button
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Follow functionality will be implemented
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Follow'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 