/// Application-wide constants: route names, Firestore collections, role prefixes.
abstract class AppConstants {
  // ─── App Info ────────────────────────────────────────────────────────────────
  static const String appName = 'PSG Mess Token';
  static const String appVersion = '2.0.0';

  // ─── Firestore Collections ───────────────────────────────────────────────────
  static const String colStudents = 'Students';
  static const String colEmployees = 'Employees';
  static const String colManagers = 'Manager';
  static const String colAdmins = 'Admins';
  static const String colTokens = 'Tokens';
  static const String docTokenCounts = 'Counts';

  // ─── Firestore Field Names ───────────────────────────────────────────────────
  static const String fieldPassword = 'Password';
  static const String fieldName = 'name';
  static const String fieldCourse = 'course';
  static const String fieldDob = 'Date of Birth';
  static const String fieldDoj = 'Date of Join';
  static const String fieldCreatedAt = 'Date of created';
  static const String fieldRole = 'role';
  static const String fieldVeg = 'veg';
  static const String fieldNonVeg = 'non-veg';
  static const String fieldEggs = 'eggs';
  static const String fieldVegPurchased = 'veg_purchased';
  static const String fieldNonVegPurchased = 'non-veg_purchased';

  // ─── Role Identifiers (stored in Firestore) ──────────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleEmployee = 'employee';
  static const String roleStudent = 'student';

  // ─── Username Prefix Detection ───────────────────────────────────────────────
  // Students: roll number starting with '2' (e.g., 23EE01)
  static const String prefixStudent = '2';
  // Employees: ID starting with 'e' or 'E'
  static const String prefixEmployee = 'e';
  // Managers: ID starting with 'm' or 'M'
  static const String prefixManager = 'm';
  // Admins: ID starting with 'a' or 'A'
  static const String prefixAdmin = 'a';

  // ─── Route Names ─────────────────────────────────────────────────────────────
  static const String routeLogin = '/';
  static const String routeStudentHome = '/student/home';
  static const String routeTokenWallet = '/student/wallet';
  static const String routeQrDisplay = '/student/qr';
  static const String routeEmployeeHome = '/employee/home';
  static const String routeScanner = '/employee/scan';
  static const String routeManagerHome = '/manager/home';
  static const String routeCreateUser = '/manager/create';
  static const String routeDeleteUser = '/manager/delete';
  static const String routeAdminHome = '/admin/home';

  // ─── QR Code Type Labels ─────────────────────────────────────────────────────
  static const String qrTypeVeg = 'Veg';
  static const String qrTypeNonVeg = 'Non-Veg';
  static const String qrTypeEggs = 'Eggs';

  // ─── Validation ──────────────────────────────────────────────────────────────
  static const int studentRollLength = 6;
  static const int minPasswordLength = 10;
  static const String passwordPattern =
      r'^(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d)[A-Za-z\d!@#$%^&*(),.?":{}|<>]{10,}$';

  // ─── Courses ─────────────────────────────────────────────────────────────────
  static const List<String> courses = [
    'Automobile Engineering',
    'Biomedical Engineering',
    'Civil Engineering',
    'Computer Science and Engineering (AI and ML)',
    'Computer Science Engineering',
    'Electrical and Electronics Engineering',
    'Instrumentation and Control Engineering',
    'Mechanical Engineering',
    'Metallurgical Engineering',
    'Production Engineering',
    'Robotics Engineering',
    'Bio Technology',
    'Fashion Technology',
    'Information Technology',
    'Textile Technology',
    'Electrical and Electronics Engineering (Sandwich)',
    'Mechanical Engineering (Sandwich)',
    'Production Engineering (Sandwich)',
    'Applied Science',
    'Computer Systems and Design',
    'Applied Electronics',
    'Automobile Electronics',
    'Biometrics and Cybersecurity',
    'Communication Systems',
    'Computer Integrated and Manufacturing',
    'Msc Software Systems',
    'Msc Cyber Security',
    'Msc Data Science',
    'Msc Theoretical Computer Science',
    'Msc Applied Mathematics',
    'MBA',
  ];
}
