import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Tokens/pages/Manager/employee_create.dart';
import 'package:Tokens/pages/Manager/employee_delete.dart';
import 'package:Tokens/pages/Manager/manger.dart';
import 'package:Tokens/pages/Manager/student_create.dart';
import 'package:Tokens/pages/Manager/student_delete.dart';
import 'package:Tokens/pages/Manager/token_notifier.dart';
import 'package:Tokens/pages/Employees/employee_page.dart';
import 'package:Tokens/pages/Employees/scanner_page.dart';
import 'package:Tokens/pages/Students/home_page.dart';
import 'package:Tokens/pages/Students/register_item.dart';
import 'package:Tokens/pages/Students/useit_page.dart';
import 'database/firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC8BWFw6OYbUUji-RrCnsEwCl_x5Rbz4sM",
        appId: "1:382286967544:android:d3d87c2ada76d28724810d",
        messagingSenderId: "382286967544",
        projectId: "token-8ecb5",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(ChangeNotifierProvider(
    create: (context) => TokenNotifier(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Register(),
      child: MaterialApp(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => LockScreen());
            case '/home':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => HomePage(
                  roll: args['roll'],
                  tokens: args['tokens'],
                ),
              );
            case '/useNV':
              final roll = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => Nveg_use(roll: roll),
              );
            case '/useV':
              final roll = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => Veg_use(roll: roll),
              );
            case '/useE':
              final roll = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => Egg_use(roll: roll),
              );
            case '/scan':
              return MaterialPageRoute(builder: (_) => const scannerPage());
            case '/worker':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => workerMenu(id: args['username']),
              );
            case '/manager':
              final token = settings.arguments as List<int>;
              return MaterialPageRoute(
                builder: (_) => managerPage(tokens: token),
              );
            case '/studentC':
              return MaterialPageRoute(builder: (_) => studentCreate());
            case '/studentD':
              return MaterialPageRoute(builder: (_) => studentDelete());
            case '/employeeC':
              return MaterialPageRoute(builder: (_) => employeeCreate());
            case '/employeeD':
              return MaterialPageRoute(builder: (_) => employeeDelete());
            default:
              return null;
          }
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
          useMaterial3: true,
        ),
      ),
    );
  }
}

class LockScreen extends StatefulWidget {
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool obsecure = true;
  String username = "";
  String password = "";
  late bool valid;
  List<int> tokens = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("image/lockbg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Card(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "PSG MESS ",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "Token",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 250,
                    child: TextField(
                      onChanged: (String name) async {
                        username = name;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Roll no',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 250,
                    height: 60,
                    child: TextField(
                      onChanged: (String pw) async {
                        password = pw;
                      },
                      obscureText: obsecure,
                      decoration: InputDecoration(
                        suffix: IconButton(
                          icon: Icon(obsecure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              obsecure = !obsecure;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  valid = await Firestore()
                      .checkCredentials(context, username, password);
                  if (valid) {
                    if (username[0].toLowerCase() == 'e') {
                      Navigator.pushNamed(
                        context,
                        '/worker',
                        arguments: {'username': username},
                      );
                    } else if (username[0].toLowerCase() == '2') {
                      tokens = await Firestore()
                          .readstudentTokenData(tokens, username);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomePage(roll: username, tokens: tokens),
                        ),
                      );
                    } else if (username[0].toLowerCase() == 'm') {
                      tokens = await Firestore().readTokens();
                      Navigator.pushNamed(
                        context,
                        '/manager',
                        arguments: tokens,
                      );
                    }
                  }
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Enter",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
