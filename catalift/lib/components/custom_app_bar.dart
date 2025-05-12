import 'package:catalift/utils/app_constants.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessageTap;

  const CustomAppBar({
    Key? key,
    this.onProfileTap,
    this.onNotificationTap,
    this.onMessageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding, 
        vertical: AppConstants.smallPadding
      ),
      height: 70,
      color: AppConstants.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CATALIFT',
            style: AppConstants.appBarTitle,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: onProfileTap,
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: onNotificationTap,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                onPressed: onMessageTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 