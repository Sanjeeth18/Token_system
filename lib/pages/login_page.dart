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





void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>Register(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) =>  LockScreen(),
          '/home': (context) => MyHomePage(),
          '/useNV' : (context) => Nveg_use(),
          '/useV' : (context) => Veg_use(),
          '/useE' : (context) => Egg_use(),
          '/scan' : (context) => scannerPage(),
          '/worker': (context) => workerMenu(),
          '/manager': (context) => managerPage(),
          '/studentC': (context) => studentCreate(),
          '/studentD' : (context) => studentDelete(),
          '/employeeC' : (context) => employeeCreate(),
          '/employeeD' : (context) => employeeDelete(),
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


class LockScreen extends StatefulWidget{
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool obsecure=true;
  late Icon eye;
  late String username;
  late String password;

  @override
  Widget build(BuildContext context){
    switch(obsecure){
      case true:
        eye=Icon(Icons.visibility_off);
      case false:
        eye=Icon(Icons.visibility);
    }
    return Container(
      decoration: BoxDecoration(
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
              Card(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: "PSG MESS ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 30,color: Colors.white)),
                        TextSpan(text: "Token", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,fontSize: 30,color:Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 250,
                    child: TextField(
                      onChanged: (String name) async{
                        username=name;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Roll no',
                      ),
                      //onSubmitted: getpassword(),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 250,
                    height: 60,
                    child: TextField(
                      onChanged: (String pw) async{
                        password=pw;
                      },
                      obscureText: obsecure,
                      decoration: InputDecoration(
                        suffix: IconButton(
                          icon: eye,
                          onPressed: (){
                            setState(() {
                              switch(obsecure){
                                case true:
                                  obsecure=false;
                                case false:
                                  obsecure=true;
                              }
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'password',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: (){

                  if(username=='s') Navigator.pushNamed(context, '/worker');
                  if(username=='h') Navigator.pushNamed(context, '/home');
                  if(username=='m') Navigator.pushNamed(context, '/manager');
                },
                child:Text.rich(
                  TextSpan(text: "Enter", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );


  }
}




