import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../screens/manager/create_user_screen.dart';
import '../../screens/manager/delete_user_screen.dart';
import '../app_button.dart';

/// Quick action row widget for Admin user management operations (Create User / Delete User).
class AdminQuickActionCard extends StatelessWidget {
  final UserSession session;

  const AdminQuickActionCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: AppOutlineButton(
              label: 'Create',
              icon: Icons.person_add_rounded,
              color: AppColors.accentLight,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateUserScreen(currentUser: session),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppOutlineButton(
              label: 'Delete',
              icon: Icons.person_remove_rounded,
              color: AppColors.error,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeleteUserScreen(currentUser: session),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
