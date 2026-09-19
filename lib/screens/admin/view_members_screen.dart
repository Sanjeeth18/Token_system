import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../repositories/firestore_repository.dart';
import '../../widgets/app_scaffold.dart';

class ViewMembersScreen extends StatefulWidget {
  final UserSession currentUser;

  const ViewMembersScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<ViewMembersScreen> createState() => _ViewMembersScreenState();
}

class _ViewMembersScreenState extends State<ViewMembersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<UserRole, List<UserSession>> _members = {
    UserRole.admin: [],
    UserRole.manager: [],
    UserRole.employee: [],
    UserRole.student: [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final data = await FirestoreRepository.instance.getAllMembersGrouped();
      if (mounted) {
        setState(() {
          _members = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'System Members',
      showBackButton: true,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accentLight,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(text: 'Admin'),
              Tab(text: 'Manager'),
              Tab(text: 'Staff'),
              Tab(text: 'Student'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMemberList(_members[UserRole.admin] ?? [], UserRole.admin),
                      _buildMemberList(_members[UserRole.manager] ?? [], UserRole.manager),
                      _buildMemberList(_members[UserRole.employee] ?? [], UserRole.employee),
                      _buildMemberList(_members[UserRole.student] ?? [], UserRole.student),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(List<UserSession> members, UserRole role) {
    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'No ${role.displayName} accounts found',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMembers,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                    backgroundImage: member.photoUrl != null &&
                            member.photoUrl!.isNotEmpty
                        ? NetworkImage(member.photoUrl!)
                        : null,
                    child: (member.photoUrl == null || member.photoUrl!.isEmpty)
                        ? Text(
                            member.name.isNotEmpty
                                ? member.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.accentLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                member.id,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (member.email != null && member.email!.isNotEmpty)
                          Text(
                            member.email!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (member.department != null &&
                            member.department!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${role == UserRole.student ? "Course" : "Dept"}: ${member.department}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
