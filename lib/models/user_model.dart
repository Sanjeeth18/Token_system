import '../core/constants/app_constants.dart';

/// Role enumeration for the entire application.
enum UserRole {
  admin,
  manager,
  employee,
  student;

  /// Derives role from username or email prefix/local-part (case-insensitive).
  static UserRole? fromUsername(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    String text = trimmed;
    if (text.contains('@')) {
      text = text.split('@').first;
    }

    final lower = text.toLowerCase();
    if (lower.startsWith('admin')) return UserRole.admin;
    if (lower.startsWith('manager')) return UserRole.manager;
    if (lower.startsWith('employee') || lower.startsWith('staff')) return UserRole.employee;
    if (lower.startsWith('student')) return UserRole.student;

    if (text.isEmpty) return null;
    final prefix = text[0].toLowerCase();
    switch (prefix) {
      case 'a':
        return UserRole.admin;
      case 'm':
        return UserRole.manager;
      case 'e':
        return UserRole.employee;
      case 's':
      case '2':
        return UserRole.student;
      default:
        return null;
    }
  }

  /// Parses role from a standard role string (e.g. 'admin', 'manager', 'employee', 'student').
  static UserRole? fromRoleString(String? roleStr) {
    if (roleStr == null) return null;
    switch (roleStr.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'employee':
      case 'staff':
        return UserRole.employee;
      case 'student':
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
        return 'Staff';
      case UserRole.student:
        return 'Student';
    }
  }

  /// Returns 'Roll Number' for Student and 'User ID' for Admin, Manager, Staff.
  String get idLabel {
    return this == UserRole.student ? 'Roll Number' : 'User ID';
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
        // Manager can only manage students and staff
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
  final String? email;
  final String? department;
  final String? photoUrl;
  final String? uid;
  final String? dob;
  final String? doj;

  const UserSession({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.department,
    this.photoUrl,
    this.uid,
    this.dob,
    this.doj,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'email': email,
        'department': department,
        'photoUrl': photoUrl,
        'uid': uid,
        'dob': dob,
        'doj': doj,
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        id: json['id'] as String,
        name: json['name'] as String,
        role: UserRole.fromRoleString(json['role'] as String?) ?? UserRole.student,
        email: json['email'] as String?,
        department: json['department'] as String?,
        photoUrl: json['photoUrl'] as String?,
        uid: json['uid'] as String?,
        dob: json['dob'] as String?,
        doj: json['doj'] as String?,
      );

  UserSession copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? email,
    String? department,
    String? photoUrl,
    String? uid,
    String? dob,
    String? doj,
  }) {
    return UserSession(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      department: department ?? this.department,
      photoUrl: photoUrl ?? this.photoUrl,
      uid: uid ?? this.uid,
      dob: dob ?? this.dob,
      doj: doj ?? this.doj,
    );
  }

  @override
  String toString() => 'UserSession(id: $id, name: $name, role: ${role.displayName})';
}
