import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:token_system/database/firebase.dart';

class managerPage extends StatefulWidget {
  final tokens;
  managerPage({super.key, required this.tokens});

  @override
  State<managerPage> createState() => _managerPageState();
}

class _managerPageState extends State<managerPage> {
  late var now;
  late var formatter;
  late String formattedDate;
  late var day;
  late var dayformat;
  late var dateformat;
  @override
  Widget build(BuildContext context) {
    now = DateTime.now();
    day = now.toUtc().weekday;
    if (day == 5 || day == 2 || day == 7) {
      now = now.add(const Duration(days: 2));
    } else if (day == 1 || day == 3 || day == 6) {
      now = now.add(const Duration(days: 1));
    } else if (day == 4) {
      now = now.add(const Duration(days: 3));
    }
    formatter = DateFormat("dd-MM-yyyy\n(EEEE)");
    formattedDate = formatter.format(now);
    return Container(
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(
                flex: 1,
              ),
              Card(
                child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text('Token count on this day!'),
                  ),
                  Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 20),
                      child: Text(
                        formattedDate,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  //Divider(),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                "Veg token \npurchased",
                                textAlign: TextAlign.center,
                              ),
                              Text("${widget.tokens[1]}"),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                "Non-Veg token\npurchased",
                                textAlign: TextAlign.center,
                              ),
                              Text("${widget.tokens[0]}"),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  //Divider(),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                "Veg token \nused",
                                textAlign: TextAlign.center,
                              ),
                              Text("${widget.tokens[3]}"),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Card(
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                "Non-Veg token\nused",
                                textAlign: TextAlign.center,
                              ),
                              Text("${widget.tokens[2]}"),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  ElevatedButton(
                      onPressed: ()  {
                            // setState(()async {
                            //                           widget.tokens=await Firestore().readTokens();

                            // });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Refresh  '), Icon(Icons.refresh)],
                      )),
                ]),
              ),
              const Spacer(
                flex: 1,
              ),
              Card(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Use these to make \nchanges in the users',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: DropdownButton(
                          elevation: 0,
                          isExpanded: true,
                          iconSize: 30,
                          icon: const Icon(Icons.arrow_downward),
                          items: const [
                            DropdownMenuItem(
                              value: '0',
                              child: Text('Create new account'),
                            ),
                            DropdownMenuItem(
                                value: '1',
                                child: Row(
                                  children: [
                                    Text("Student"),
                                    Spacer(),
                                    Icon(Icons.arrow_forward)
                                  ],
                                )),
                            DropdownMenuItem(
                              value: '2',
                              child: Row(
                                children: [
                                  Text('Employee'),
                                  Spacer(),
                                  Icon(Icons.arrow_forward)
                                ],
                              ),
                            ),
                          ],
                          value: '0',
                          onChanged: (value) {
                            if (value == '1') {
                              Navigator.pushNamed(context, '/studentC');
                            } else if (value == '2') {
                              Navigator.pushNamed(context, '/employeeC');
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: DropdownButton(
                          elevation: 0,
                          isExpanded: true,
                          iconSize: 30,
                          icon: const Icon(Icons.arrow_downward),
                          items: const [
                            DropdownMenuItem(
                              value: '0',
                              child: Text('Delete an account'),
                            ),
                            DropdownMenuItem(
                                value: '1',
                                child: Row(
                                  children: [
                                    Text("Student"),
                                    Spacer(),
                                    Icon(Icons.arrow_forward)
                                  ],
                                )),
                            DropdownMenuItem(
                              value: '2',
                              child: Row(
                                children: [
                                  Text('Employee'),
                                  Spacer(),
                                  Icon(Icons.arrow_forward)
                                ],
                              ),
                            ),
                          ],
                          value: '0',
                          onChanged: (value) {
                            if (value == '1') {
                              Navigator.pushNamed(context, '/studentD');
                            } else if (value == '2') {
                              Navigator.pushNamed(context, '/employeeD');
                            }
                          }),
                    ),
                  ],
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      child: const Text("Log Out")),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}