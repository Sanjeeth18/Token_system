import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class studentCreate extends StatefulWidget {
  studentCreate({super.key});

  @override
  State<studentCreate> createState() => _studentCreateState();
}

class _studentCreateState extends State<studentCreate> {
  var roll,name,dob="enter dob",date,doj='enter doj',password;
  int inserted=1;
  var options=['Select the course',
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
    'Electrical and Electronics Engineering(Sandwich)',
    'Mechanical Engineering(Sandwich)',
    'Production Engineering(Sandwich)',
    'Applied Science',
    'Computer Systems and Design',
    'Applied Electronics',
    'Automobile Electronics',
    'Biometrics and Cybersecurity',
    'Communication Systems',
    'Compiuter Integrated and Manufacturing',
    'Msc Software Systems',
    'Msc Cyber Security',
    'Msc Data Science',
    'Msc Theoretical Computer Science',
    'Msc Applied Mathematics',
    'MBA'];
  var course='Select the course';
  int error_course=0;
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
          body: ListView(
            children: [
              SizedBox(height: 30,),
              Center(
                child: Text(
                  "Create Student account",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              SizedBox(height:30),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  height: 500,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Spacer(flex: 1,),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter roll number',
                                  hintStyle: TextStyle(color: Colors.black)),
                              validator: (String? value) {
                                if (value == null || value.isEmpty || value.length!=6) {
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: TextFormField(
                            decoration: InputDecoration(
                                hintText: 'Enter Password',
                                hintStyle: TextStyle(color: Colors.black)),
                            validator: (String? value) {
                              if (value == null || value.isEmpty || value.length<7) {
                                return 'Enter this field';
                              }
                              return null;
                            },
                            onChanged: (value){
                              setState(() {
                                password=value;
                              });
                            },
                          ),
                        ),Spacer(
                            flex:1
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: DropdownButton<String>(
                            value: course,
                            itemHeight: 75,
                            icon:  Icon(Icons.arrow_downward),
                            onChanged: (String? value){
                              setState(() {
                                course=value!;
                              });
                            },
                            items: options.map<DropdownMenuItem<String>>((String value){
                              return DropdownMenuItem(child: SizedBox(height:100,width:250,child: Text(value)),value: value,);
                            }
                            ).toList(),
                          )
                          ),
                        if(error_course==1)
                          Text("Select valid")
                        ,
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
                        ),
                        Padding(
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
                        ),Spacer(
                          flex: 1,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height:30),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 60),
                child: ElevatedButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate()){

                        print("$roll , $name , $course , $dob");
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Student added !'))
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
              SizedBox(height:30),
            ],
          )),
    );
  }
}
