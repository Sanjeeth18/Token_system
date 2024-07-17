import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/firebase.dart';

class studentCreate extends StatefulWidget {
  studentCreate({super.key});

  @override
  State<studentCreate> createState() => _studentCreateState();
}

class _studentCreateState extends State<studentCreate> {
  var roll, name, dob = "enter dob", date, doj = 'enter doj', password;
  int inserted = 1;
  var options = [
    'Select the course',
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
    'Computer Integrated and Manufacturing',
    'Msc Software Systems',
    'Msc Cyber Security',
    'Msc Data Science',
    'Msc Theoretical Computer Science',
    'Msc Applied Mathematics',
    'MBA'
  ];
  var course = 'Select the course';
  int errorCourse = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool valid;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          children: [
            const SizedBox(
              height: 30,
            ),
            const Center(
              child: Text(
                "Create Student account",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                height: 500,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'Enter roll number',
                              hintStyle: TextStyle(color: Colors.black)),
                          validator: (String? value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length != 6) {
                              return 'Enter this field';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              roll = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'Enter name',
                              hintStyle: TextStyle(color: Colors.black)),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter this field';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              name = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        child: TextFormField(
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            hintStyle:const  TextStyle(color: Colors.black),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: (String? value) {
                            String pattern =
                                r'^(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d)[A-Za-z\d!@#$%^&*(),.?":{}|<>]{10,}$';
                            RegExp expression = RegExp(pattern);
                            if (value == null || value.isEmpty) {
                              return 'Enter this field';
                            } else if (value.length < 10) {
                              return 'Password length must be within or equal to 10 characters long';
                            } else if (!expression.hasMatch(value)) {
                              return 'Password must contain at least one symbol and one number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DropdownButton<String>(
                            value: course,
                            itemHeight: 75,
                            icon: const Icon(Icons.arrow_downward),
                            onChanged: (String? value) {
                              setState(() {
                                course = value!;
                              });
                            },
                            items: options.map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: SizedBox(
                                    height: 100,
                                    width: 250,
                                    child: Text(value)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      if (errorCourse == 1)
                        const Text(
                          "Select valid",
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(dob),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1970),
                                          lastDate: DateTime.now())
                                      .then((value) {
                                    setState(() {
                                      date = value;
                                      dob = DateFormat("dd-MM-yyyy")
                                          .format(date);
                                    });
                                  });
                                },
                                icon: const Icon(Icons.calendar_today))
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(doj),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1970),
                                          lastDate: DateTime.now())
                                      .then((value) {
                                    setState(() {
                                      date = value;
                                      doj = DateFormat("dd-MM-yyyy")
                                          .format(date);
                                    });
                                  });
                                },
                                icon: const Icon(Icons.calendar_today))
                          ],
                        ),
                      ),
                      if (!_isValidAge())
                        const Text(
                          'Date of joining must be at least 18 years after Date of birth',
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _isValidAge()) {
                      valid = await Firestore().CreateStudent(
                          name, roll, course, dob, doj, password);
                      if (valid == true) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Student added!')));
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Already exists')));
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Create"),
                      Spacer(),
                      Icon(Icons.arrow_forward)
                    ],
                  ),
                )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  bool _isValidAge() {
    if (date == null) return false;
    DateTime dobDate = DateTime.parse(dob);
    DateTime dojDate = DateTime.parse(doj);
    DateTime minDojDate = dobDate.add(Duration(days: 18 * 365));
    return !dojDate.isBefore(minDojDate);
  }
}
