import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/employee/employee_screen.dart';
import 'screens/employee/scanner_screen.dart';
import 'screens/manager/create_user_screen.dart';
import 'screens/manager/delete_user_screen.dart';
import 'screens/manager/manager_screen.dart';
import 'screens/student/student_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables securely from .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv load note: $e');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase using platform configuration (google-services.json / GoogleService-Info.plist)
  // No hardcoded credentials are included.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  runApp(
    const ProviderScope(
      child: PsgTokenApp(),
    ),
  );
}

class PsgTokenApp extends ConsumerStatefulWidget {
  const PsgTokenApp({super.key});

  @override
  ConsumerState<PsgTokenApp> createState() => _PsgTokenAppState();
}

class _PsgTokenAppState extends ConsumerState<PsgTokenApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(authProvider.notifier).onAppResumed();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      ref.read(authProvider.notifier).onAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    Widget homeWidget = const LoginScreen();
    if (authState is AuthAuthenticated) {
      final session = authState.session;
      switch (session.role) {
        case UserRole.admin:
          homeWidget = AdminScreen(session: session);
          break;
        case UserRole.manager:
          homeWidget = ManagerScreen(session: session);
          break;
        case UserRole.employee:
          homeWidget = EmployeeScreen(session: session);
          break;
        case UserRole.student:
          homeWidget = StudentHomeScreen(session: session);
          break;
      }
    }

    return MaterialApp(
      title: 'PSG Mess Token',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: homeWidget,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppConstants.routeLogin:
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
              settings: settings,
            );

          case AppConstants.routeStudentHome:
            final session = settings.arguments as UserSession;
            return MaterialPageRoute(
              builder: (_) => StudentHomeScreen(session: session),
              settings: settings,
            );

          case AppConstants.routeEmployeeHome:
            final session = settings.arguments as UserSession;
            return MaterialPageRoute(
              builder: (_) => EmployeeScreen(session: session),
              settings: settings,
            );

          case AppConstants.routeManagerHome:
            final session = settings.arguments as UserSession;
            return MaterialPageRoute(
              builder: (_) => ManagerScreen(session: session),
              settings: settings,
            );

          case AppConstants.routeAdminHome:
            final session = settings.arguments as UserSession;
            return MaterialPageRoute(
              builder: (_) => AdminScreen(session: session),
              settings: settings,
            );

          case AppConstants.routeScanner:
            return MaterialPageRoute(
              builder: (_) => const ScannerScreen(),
              settings: settings,
            );

          case AppConstants.routeCreateUser:
            final session = settings.arguments as UserSession;
            return MaterialPageRoute(
              builder: (_) => CreateUserScreen(currentUser: session),
              settings: settings,
            );

          case AppConstants.routeDeleteUser:
            final session = settings.arguments as UserSession;
            return MaterialPageRoute(
              builder: (_) => DeleteUserScreen(currentUser: session),
              settings: settings,
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
              settings: settings,
            );
        }
      },
    );
  }
}
