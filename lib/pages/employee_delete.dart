import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class employeeDelete extends StatefulWidget {
  employeeDelete({super.key});

  @override
  State<employeeDelete> createState() => _employeeDeleteState();
}

class _employeeDeleteState extends State<employeeDelete> {
  var roll;

  final GlobalKey<FormState> _formKey=GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
        LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(flex: 2,),
                Text(
                  "Delete employee account",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Spacer(flex: 1,),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    height: 120,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter employee code',
                                  hintStyle: TextStyle(color: Colors.black)),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter this field';
                                }
                                return null;
                              },
                              onChanged: (value){
                                setState(() {
                                  roll=value;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 2,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 60),
                  child: ElevatedButton(
                      onPressed: () {
                        if(_formKey.currentState!.validate()){
                          print("$roll");
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('employee deleted !'))
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Delete"),
                          Spacer(),
                          Icon(Icons.arrow_forward)
                        ],
                      )
                  ),
                ),
                Spacer(flex: 2,),
              ],
            ),
          )),
    );
  }
}
