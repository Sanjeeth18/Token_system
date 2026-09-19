import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';

/// Reusable Role Selection Card widget for user creation.
class RoleSelectionCard extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleSelected;
  final bool canCreateAdmin;

  const RoleSelectionCard({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
    this.canCreateAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roles = [
            UserRole.student,
            UserRole.employee,
            UserRole.manager,
            if (canCreateAdmin) UserRole.admin,
          ];

          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: roles.map((role) {
              final isSelected = selectedRole == role;
              return SizedBox(
                width: (constraints.maxWidth - 8) / (roles.length > 2 ? 2 : roles.length),
                child: InkWell(
                  onTap: () => onRoleSelected(role),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        role.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
