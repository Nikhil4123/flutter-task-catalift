import 'package:catalift/models/post_model.dart';
import 'package:catalift/services/service_provider.dart';
import 'package:catalift/utils/app_constants.dart';
import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUserId;
  final Function(String) onCommentTap;
  final Function(String) onShareTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onPostUpdate;

  const PostCard({
    Key? key,
    required this.post,
    required this.currentUserId,
    required this.onCommentTap,
    required this.onShareTap,
    this.onProfileTap,
    this.onPostUpdate,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final ServiceProvider _serviceProvider = ServiceProvider();
  late bool _isLiked;
  late int _likeCount;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likes.contains(widget.currentUserId);
    _likeCount = widget.post.likes.length;
  }

  Future<void> _handleLike() async {
    // Don't allow anonymous likes
    if (widget.currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like posts')),
      );
      return;
    }

    // Prevent multiple rapid taps
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      // Optimistically update UI
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });

    try {
      await _serviceProvider.likePost(widget.post.id, widget.currentUserId);
      
      // Notify parent if needed
      if (widget.onPostUpdate != null) {
        widget.onPostUpdate!();
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding, 
        vertical: AppConstants.smallPadding
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTitle(),
          _buildContent(),
          if (widget.post.imageUrl != null) _buildImage(),
          _buildStats(),
          const Divider(height: 1),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onProfileTap,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: widget.post.userProfileImage != null 
                ? NetworkImage(widget.post.userProfileImage!) 
                : null,
              child: widget.post.userProfileImage == null 
                ? Text(widget.post.userName[0].toUpperCase())
                : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.userName,
                  style: AppConstants.userName,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (widget.post.userRole != null)
                      Text(
                        widget.post.userRole!,
                        style: AppConstants.userRole,
                      ),
                    if (widget.post.userRole != null)
                      const SizedBox(width: 8),
                    _buildTimeDot(),
                    Text(
                      _getTimeAgo(),
                      style: AppConstants.userRole,
                    ),
                    if (widget.post.editedAt != null) ...[
                      const SizedBox(width: 8),
                      _buildTimeDot(),
                      const Text(
                        'Edited',
                        style: AppConstants.userRole,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_add_outlined, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Text(
        widget.post.title,
        style: AppConstants.postTitle,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Text(
        widget.post.content,
        style: AppConstants.postContent,
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Image.network(
        widget.post.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(Icons.image, size: 50, color: Colors.grey.shade400),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '$_likeCount Stars',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '${widget.post.commentsCount} comments',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: _isLiking ? null : _handleLike,
            icon: _isLiking 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isLiked ? Icons.star : Icons.star_border,
                    color: _isLiked ? Colors.amber : Colors.black,
                  ),
            label: const Text(''),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () => widget.onCommentTap(widget.post.id),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text(''),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () => widget.onShareTap(widget.post.id),
            icon: const Icon(Icons.send),
            label: const Text(''),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.post.createdAt);
    
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
      return 'now';
    }
  }
} 