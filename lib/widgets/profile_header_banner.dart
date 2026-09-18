import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';

/// Reusable profile header banner for user dashboard screens.
class ProfileHeaderBanner extends StatelessWidget {
  final UserSession session;
  final String? subtitle;
  final Widget? trailingBadge;
  final Widget? extraInfo;

  const ProfileHeaderBanner({
    super.key,
    required this.session,
    this.subtitle,
    this.trailingBadge,
    this.extraInfo,
  });

  @override
  Widget build(BuildContext context) {
    final role = session.role;
    final Gradient bgGradient;
    final Color badgeColor;
    final IconData iconData;

    switch (role) {
      case UserRole.admin:
        bgGradient = AppColors.adminGradient;
        badgeColor = AppColors.adminBadge;
        iconData = Icons.shield_rounded;
        break;
      case UserRole.manager:
        bgGradient = AppColors.cardGradient;
        badgeColor = AppColors.managerBadge;
        iconData = Icons.admin_panel_settings_rounded;
        break;
      case UserRole.employee:
        bgGradient = AppColors.cardGradient;
        badgeColor = AppColors.employeeBadge;
        iconData = Icons.qr_code_scanner_rounded;
        break;
      case UserRole.student:
        bgGradient = AppColors.accentGradient;
        badgeColor = AppColors.studentBadge;
        iconData = Icons.person_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: badgeColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            session.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trailingBadge != null) ...[
                          const SizedBox(width: 8),
                          trailingBadge!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle ?? '${role.idLabel}: ${session.id}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (extraInfo != null) ...[
            const SizedBox(height: 16),
            extraInfo!,
          ],
        ],
      ),
    );
  }
}
