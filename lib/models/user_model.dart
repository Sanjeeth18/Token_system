import '../core/constants/app_constants.dart';

/// Role enumeration for the entire application.
enum UserRole {
  admin,
  manager,
  employee,
  student;

  /// Derives role from username prefix (case-insensitive).
  static UserRole? fromUsername(String username) {
    if (username.isEmpty) return null;
    final prefix = username[0].toLowerCase();
    switch (prefix) {
      case 'a':
        return UserRole.admin;
      case 'm':
        return UserRole.manager;
      case 'e':
        return UserRole.employee;
      case '2':
        return UserRole.student;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.employee:
        return 'Employee';
      case UserRole.student:
        return 'Student';
    }
  }

  String get firestoreCollection {
    switch (this) {
      case UserRole.admin:
        return AppConstants.colAdmins;
      case UserRole.manager:
        return AppConstants.colManagers;
      case UserRole.employee:
        return AppConstants.colEmployees;
      case UserRole.student:
        return AppConstants.colStudents;
    }
  }

  /// Whether this role can manage (create/delete) the [target] role.
  bool canManage(UserRole target) {
    switch (this) {
      case UserRole.admin:
        // Admin can manage everyone except other admins
        return target != UserRole.admin;
      case UserRole.manager:
        // Manager can only manage students and employees
        return target == UserRole.student || target == UserRole.employee;
      case UserRole.employee:
      case UserRole.student:
        return false;
    }
  }

  /// Whether this role has manager-level or higher access.
  bool get isManagerOrAbove =>
      this == UserRole.manager || this == UserRole.admin;

  bool get isAdmin => this == UserRole.admin;
}

/// Represents an authenticated user session.
class UserSession {
  final String id;
  final String name;
  final UserRole role;

  const UserSession({
    required this.id,
    required this.name,
    required this.role,
  });

  @override
  String toString() => 'UserSession(id: $id, role: ${role.displayName})';
}
