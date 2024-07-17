import 'package:flutter/material.dart';
import 'package:token_system/database/Firebase.dart';

class employeeDelete extends StatefulWidget {
  employeeDelete({super.key});

  @override
  State<employeeDelete> createState() => _employeeDeleteState();
}

class _employeeDeleteState extends State<employeeDelete> {
  var roll;
  late bool valid;

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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 2,
                ),
                const Text(
                  "Delete employee account",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const Spacer(
                  flex: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: const BoxDecoration(
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
                              decoration: const InputDecoration(
                                  hintText: 'Enter employee code',
                                  hintStyle: TextStyle(color: Colors.black)),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
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
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 2,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          valid =
                              await Firestore().delete_student_employee(roll);
                          if (valid) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('employee deleted !')));
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$roll not exists.')));
                          }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Delete"),
                          Spacer(),
                          Icon(Icons.arrow_forward)
                        ],
                      )),
                ),
                const Spacer(
                  flex: 2,
                ),
              ],
            ),
          )),
    );
  }
}
