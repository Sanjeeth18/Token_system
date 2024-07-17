import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/firebase.dart';

class employeeCreate extends StatefulWidget {
  employeeCreate({super.key});

  @override
  State<employeeCreate> createState() => _employeeCreateState();
}

class _employeeCreateState extends State<employeeCreate> {
  var id, name, dob = "Enter DOB", date, doj = "Enter DOJ", password;
  late bool valid;
  bool obscure = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Create Employee account",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter employee id',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter this field';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                id = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter name',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
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
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Enter Password',
                              hintStyle: const TextStyle(color: Colors.black),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscure = !obscure;
                                  });
                                },
                              ),
                            ),
                            obscureText: obscure,
                            validator: (String? value) {
                              String pattern =
                                  r'^(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d)[A-Za-z\d!@#$%^&*(),.?":{}|<>]{10,}$';
                              RegExp expression = RegExp(pattern);
                              if (value == null || value.isEmpty) {
                                return 'Enter this field';
                              } else if (value.length < 10) {
                                return 'Password must be at least 10 characters long';
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
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(doj),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1970),
                                    lastDate: DateTime.now(),
                                  ).then((value) {
                                    setState(() {
                                      date = value;
                                      doj =
                                          DateFormat("dd-MM-yyyy").format(date);
                                    });
                                  });
                                },
                                icon: const Icon(Icons.calendar_today),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(dob),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1970),
                                    lastDate: DateTime.now(),
                                  ).then((value) {
                                    setState(() {
                                      date = value;
                                      dob =
                                          DateFormat("dd-MM-yyyy").format(date);
                                      _formKey.currentState!.validate();
                                    });
                                  });
                                },
                                icon: const Icon(Icons.calendar_today),
                              ),
                            ],
                          ),
                          if (dob != "Enter DOB" && doj != "Enter DOJ")
                            if (date != null &&
                                date.isBefore(DateTime.now()
                                    .subtract(Duration(days: 23 * 365))))
                              const Text(
                                'Date of joining must be after 23 years of Date of birth',
                                style: TextStyle(color: Colors.red),
                              )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      valid = await Firestore()
                          .CreateEmployee(name, id, dob, doj, password);
                      if (valid == true) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Employee added!')),
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Already Exists!')),
                        );
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Create"),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
