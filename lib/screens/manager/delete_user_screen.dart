import 'package:flutter/material.dart';
import '../../core/error/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../repositories/firestore_repository.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_dialog.dart';

class DeleteUserScreen extends StatefulWidget {
  final UserSession currentUser;

  const DeleteUserScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<DeleteUserScreen> createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<UserSession> _allUsers = [];
  List<UserSession> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final list = await FirestoreRepository.instance.getAllEligibleDeleteUsers(widget.currentUser);
      if (mounted) {
        setState(() {
          _allUsers = list;
          _filteredUsers = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredUsers = _allUsers);
    } else {
      setState(() {
        _filteredUsers = _allUsers.where((u) {
          return u.name.toLowerCase().contains(query) ||
              u.id.toLowerCase().contains(query) ||
              (u.email != null && u.email!.toLowerCase().contains(query));
        }).toList();
      });
    }
  }

  Future<void> _handleDeleteUser(UserSession user) async {
    final confirmed = await AppFeedback.showConfirmationDialog(
      context,
      title: 'Delete Member Account',
      message:
          'Are you sure you want to permanently delete ${user.role.displayName} "${user.name}" (${user.role.idLabel}: ${user.id})? This action cannot be undone.',
      confirmLabel: 'Delete Forever',
      isDestructive: true,
    );

    if (!confirmed) return;

    try {
      await FirestoreRepository.instance.deleteUser(user.id, widget.currentUser);
      if (!mounted) return;
      AppFeedback.showSnackBar(
        context,
        'Member "${user.name}" (${user.id}) successfully deleted.',
        isError: false,
      );
      _loadUsers();
    } on UserNotFoundException {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'User "${user.id}" not found', isError: true);
      }
    } on PermissionDeniedException {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Permission denied', isError: true);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Error deleting user: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Delete Member Account',
      showBackButton: true,
      userRole: widget.currentUser.role,
      body: Column(
        children: [
          // Danger Warning Banner & Search Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withValues(alpha: 0.15),
                        AppColors.surfaceElevated,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Permanent Account Removal',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Deleting a member purges all credentials and associated token records.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Search Bar with Count Badge
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: '',
                        hint: 'Search by name, roll, or email...',
                        controller: _searchController,
                        prefixIcon: Icons.search_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MEMBERS DIRECTORY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.accentLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_filteredUsers.length} found',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No matching members found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try searching with a different name or ID',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        color: AppColors.accent,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            final isStudent = user.role == UserRole.student;
                            final isEmployee = user.role == UserRole.employee;

                            final roleColor = isStudent
                                ? AppColors.vegGreen
                                : (isEmployee ? AppColors.warning : AppColors.accent);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: roleColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: roleColor.withValues(alpha: 0.4), width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: roleColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: roleColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        user.role.displayName.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: roleColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user.role.idLabel}: ${user.id}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accentLight,
                                        ),
                                      ),
                                      if (user.email != null && user.email!.isNotEmpty)
                                        Text(
                                          user.email!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever_rounded,
                                      color: AppColors.error,
                                      size: 22,
                                    ),
                                    onPressed: () => _handleDeleteUser(user),
                                    tooltip: 'Delete Member',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
