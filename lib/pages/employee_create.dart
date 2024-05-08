import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class employeeCreate extends StatefulWidget {
  employeeCreate({super.key});

  @override
  State<employeeCreate> createState() => _employeeCreateState();
}

class _employeeCreateState extends State<employeeCreate> {
  var roll,name,course,dob="enter DOB",date,doj="enter DOJ";

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
                  "Create Employee account",
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
                    height: 400,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Spacer(flex: 1,),
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
                          ),Spacer(
                            flex: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 30),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter name',
                                  hintStyle: TextStyle(color: Colors.black)),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter this field';
                                }
                                return null;
                              },
                              onChanged: (value){
                                setState(() {
                                  name=value;
                                });
                              },
                            ),
                          ),Spacer(
                              flex:1
                          ),Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(doj),
                                Spacer(),
                                IconButton(
                                    onPressed: (){
                                      showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1970),
                                          lastDate: DateTime.now()
                                      ).then((value) {
                                        setState(() {
                                          date=value;
                                          doj=DateFormat("dd-MM-yyyy").format(date);
                                        });
                                      });
                                    },
                                    icon: Icon(Icons.calendar_today)
                                )
                              ],
                            ),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(dob),
                                Spacer(),
                                IconButton(
                                    onPressed: (){
                                      showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1970),
                                          lastDate: DateTime.now()
                                      ).then((value) {
                                        setState(() {
                                          date=value;
                                          dob=DateFormat("dd-MM-yyyy").format(date);
                                        });
                                      });
                                    },
                                    icon: Icon(Icons.calendar_today)
                                )
                              ],
                            ),
                          ),Spacer(
                            flex: 1,
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
                          print("$roll , $name , $course , $dob");
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Employee added !'))
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Create"),
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
