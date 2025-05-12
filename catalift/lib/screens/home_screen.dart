import 'package:catalift/components/custom_app_bar.dart';
import 'package:catalift/components/custom_bottom_nav.dart';
import 'package:catalift/components/custom_search_bar.dart';
import 'package:catalift/components/post_card.dart';
import 'package:catalift/models/post_model.dart';
import 'package:catalift/models/user_model.dart';
import 'package:catalift/screens/login_screen.dart';
import 'package:catalift/services/auth_service.dart';
import 'package:catalift/services/mock_data_service.dart';
import 'package:catalift/utils/app_constants.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MockDataService _dataService = MockDataService();
  
  int _currentNavIndex = 0;
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      if (_searchQuery.isEmpty) {
        _posts = _dataService.posts;
      } else {
        _posts = _dataService.searchPosts(_searchQuery);
      }
      _isLoading = false;
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadPosts();
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _handleAddPost() {
    final UserModel? currentUser = AuthService().currentUser;
    if (currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildCreatePostModal(currentUser),
    );
  }

  void _handleCommentTap(String postId) {
    final post = _posts.firstWhere((post) => post.id == postId);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildCommentsModal(post),
    );
  }

  void _handleShareTap(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing functionality will be implemented with Firebase')),
    );
  }

  void _handleLogout() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(AppConstants.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppConstants.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppConstants.yes,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await AuthService().logout();
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          CustomAppBar(
            onProfileTap: _handleLogout, // For now, profile tap logs out
            onNotificationTap: () {},
            onMessageTap: () {},
          ),
          CustomSearchBar(
            controller: _searchController,
            onChanged: _handleSearch,
            onAddTap: _handleAddPost,
          ),
          Expanded(
            child: _buildContent(),
          ),
          CustomBottomNav(
            currentIndex: _currentNavIndex,
            onTap: _handleNavTap,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No posts available'
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

    final UserModel? currentUser = AuthService().currentUser;
    final String userId = currentUser?.id ?? '';

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: _posts[index],
            currentUserId: userId,
            onCommentTap: _handleCommentTap,
            onShareTap: _handleShareTap,
          );
        },
      ),
    );
  }

  Widget _buildCreatePostModal(UserModel user) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(user.name[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.role != null)
                    Text(
                      user.role!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: contentController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Share your thoughts...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty) {
                    final newPost = PostModel(
                      id: 'post${DateTime.now().millisecondsSinceEpoch}',
                      userId: user.id,
                      userName: user.name,
                      userRole: user.role,
                      userProfileImage: user.profileImage,
                      title: titleController.text,
                      content: contentController.text,
                      createdAt: DateTime.now(),
                    );
                    
                    _dataService.addPost(newPost);
                    _loadPosts();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                ),
                child: const Text('Post'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCommentsModal(PostModel post) {
    final commentController = TextEditingController();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Comments (${post.commentsCount})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: post.comments.length,
                  itemBuilder: (context, index) {
                    final comment = post.comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: comment.userProfileImage != null
                            ? NetworkImage(comment.userProfileImage!)
                            : null,
                        child: comment.userProfileImage == null
                            ? Text(comment.userName[0].toUpperCase())
                            : null,
                      ),
                      title: Text(
                        comment.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(comment.content),
                      trailing: Text(
                        _getTimeAgo(comment.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          final UserModel? currentUser = AuthService().currentUser;
                          
                          if (currentUser != null) {
                            final newComment = CommentModel(
                              id: 'comment${DateTime.now().millisecondsSinceEpoch}',
                              userId: currentUser.id,
                              userName: currentUser.name,
                              userProfileImage: currentUser.profileImage,
                              content: commentController.text,
                              createdAt: DateTime.now(),
                            );
                            
                            _dataService.addComment(post.id, newComment);
                            commentController.clear();
                            _loadPosts();
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.send,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
} 