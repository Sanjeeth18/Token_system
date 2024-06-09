import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:token_system/pages/employee_create.dart';
import 'package:token_system/pages/employee_delete.dart';
import 'package:token_system/pages/main_page_organise.dart';
import 'package:token_system/pages/manger.dart';
import 'package:token_system/pages/register_item.dart';
import 'package:token_system/pages/student_create.dart';
import 'package:token_system/pages/student_delete.dart';
import 'package:token_system/pages/useit_page.dart';
import 'package:token_system/pages/scanner_page.dart';
import 'package:token_system/pages/employee_page.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Register(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => LockScreen(),
          '/home': (context) => const MyHomePage(),
          '/useNV': (context) => const Nveg_use(),
          '/useV': (context) => const Veg_use(),
          '/useE': (context) => const Egg_use(),
          '/scan': (context) => const scannerPage(),
          '/worker': (context) => const workerMenu(),
          '/manager': (context) => const managerPage(),
          '/studentC': (context) => studentCreate(),
          '/studentD': (context) => studentDelete(),
          '/employeeC': (context) => employeeCreate(),
          '/employeeD': (context) => employeeDelete(),
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

  @override
  Widget build(BuildContext context) {
    switch (obsecure) {
      case true:
        eye = const Icon(Icons.visibility_off);
      case false:
        eye = const Icon(Icons.visibility);
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
                      //onSubmitted: getpassword(),
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
                              switch (obsecure) {
                                case true:
                                  obsecure = false;
                                case false:
                                  obsecure = true;
                              }
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
                  valid = await checkcredentials(context, username, password);
                  if (valid == true) {
                    if (username[0].toLowerCase() == 's') {
                      Navigator.pushNamed(context, '/worker');
                    }
                    if (username[0].toLowerCase() == 'h') {
                      Navigator.pushNamed(context, '/home');
                    }
                    if (username[0] == 'M') {
                      Navigator.pushNamed(context, '/manager');
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text("Enter Valid Details"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
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

Future<bool> checkcredentials(
    BuildContext context, String username, String password) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Username and Password')
        .doc(username) // Assuming document ID is the username
        .get();
    if (snapshot.exists) {
      final storedPassword = snapshot.data()?['Password'];
      if (storedPassword == password) {
        return true;
      } else {
        // Password doesn't match
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Incorrect password"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        return false;
      }
    } else {
      // Username doesn't exist
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("The username does not exist"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return false;
    }
  } catch (e) {
    return false;
  }
}
