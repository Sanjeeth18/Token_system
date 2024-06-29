import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:token_system/pages/Manager/employee_create.dart';
import 'package:token_system/pages/Manager/employee_delete.dart';
import 'package:token_system/pages/Students/home_page.dart';
import 'package:token_system/pages/Manager/manger.dart';
import 'package:token_system/pages/Students/register_item.dart';
import 'package:token_system/pages/Manager/student_create.dart';
import 'package:token_system/pages/Manager/student_delete.dart';
import 'package:token_system/pages/Students/useit_page.dart';
import 'package:token_system/pages/Employees/scanner_page.dart';
import 'package:token_system/pages/Employees/employee_page.dart';
import '../database/firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyAKPDUFgDGDjUEuTI5IIWmKB3wAatwZR4o",
              appId: "1:475750177091:android:69af47ef61866b820b37f6",
              messagingSenderId: "475750177091",
              projectId: "token-system-bdcbc"))
      : await Firebase.initializeApp();
  runApp(const MyApp());
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
                  builder: (_) => Nveg_use(
                        roll: roll,
                      ));
            case '/useV':
              final roll = settings.arguments as String;

              return MaterialPageRoute(
                  builder: (_) => Veg_use(
                        roll: roll,
                      ));
            case '/useE':
              final roll = settings.arguments as String;

              return MaterialPageRoute(builder: (_) => Egg_use(roll: roll));
            case '/scan':
              return MaterialPageRoute(builder: (_) => const scannerPage());
            case '/worker':
              return MaterialPageRoute(builder: (_) => const workerMenu());
            case '/manager':
              final total_counts = settings.arguments as List<int>;
              return MaterialPageRoute(builder: (_) =>  managerPage(tokens: total_counts,));
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
  late Icon eye;
  late String username;
  late String password;
  late bool valid;
  List<int> tokens = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
    switch (obsecure) {
      case true:
        eye = const Icon(Icons.visibility_off);
        break;
      case false:
        eye = const Icon(Icons.visibility);
        break;
    }
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
                                color: Colors.white)),
                        TextSpan(
                            text: "Token",
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
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
              const SizedBox(
                height: 20,
              ),
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
                          icon: eye,
                          onPressed: () {
                            setState(() {
                              obsecure = !obsecure;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                        labelText: 'password',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  valid = await Firestore()
                      .checkCredentials(context, username, password);
                  if (valid == true) {
                    if (username[0].toLowerCase() == 'e') {
                      Navigator.pushNamed(context, '/worker');
                    }
                    if (username[0].toLowerCase() == '2') {
                      print("First Tokens: $tokens");
                      tokens = await Firestore()
                          .readstudentTokenData(tokens, username);

                      print("The tokens : $tokens");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(roll: username, tokens: tokens)));
                    }
                    if (username[0].toLowerCase() == 'm') {
                      tokens = await Firestore().readTokens();
                      Navigator.pushNamed(context, '/manager',arguments: tokens);
                    }
                  }
                },
                child: const Text.rich(
                  TextSpan(
                      text: "Enter",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
