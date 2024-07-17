import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:token_system/pages/Manager/token_notifier.dart';

import '../../database/firebase.dart';

class managerPage extends StatefulWidget {
  final List<int> tokens;

  const managerPage({Key? key, required this.tokens}) : super(key: key);

  @override
  State<managerPage> createState() => _managerPageState();
}

class _managerPageState extends State<managerPage> {
  late DateTime now;
  late String formattedDate;
  TextEditingController veg = TextEditingController();
  TextEditingController non = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDate();
  }

  void _initializeDate() {
    now = DateTime.now();
    int day = now.weekday;
    now = now.add(Duration(days: _getDaysToAdd(day)));
    formattedDate = DateFormat("dd-MM-yyyy\n(EEEE)").format(now);
  }

  int _getDaysToAdd(int day) {
    switch (day) {
      case DateTime.monday:
      case DateTime.wednesday:
      case DateTime.saturday:
        return 1;
      case DateTime.tuesday:
      case DateTime.friday:
      case DateTime.sunday:
        return 2;
      case DateTime.thursday:
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff000428), Color(0xff004e92)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _buildTokenCard(),
                      _buildUserManagementCard(),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/');
                            },
                            child: const Text("Log Out"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card _buildTokenCard() {
    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text('Token count on this day!'),
          ),
          Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              child: Text(
                formattedDate,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Consumer<TokenNotifier>(
            builder: (context, notifier, child) {
              return Column(
                children: [
                  Row(
                    children: [
                      _buildTokenInfoCard(
                          "Veg token \npurchased", notifier.tokens[1]),
                      _buildTokenInfoCard(
                          "Non-Veg token\npurchased", notifier.tokens[0]),
                    ],
                  ),
                  Row(
                    children: [
                      _buildTokenInfoCard(
                          "Veg token \nused", notifier.tokens[3]),
                      _buildTokenInfoCard(
                          "Non-Veg token\nused", notifier.tokens[2]),
                    ],
                  ),
                ],
              );
            },
          ),
          if (widget.tokens[0] == 0 && widget.tokens[1] == 0)
            Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: veg,
                                  decoration:const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Veg Tokens',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await Firestore().createToken(int.parse(veg.text), "veg");
                            veg.clear();  
                          },
                          child: const Text("Add"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: non,
                                  decoration:const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Non-Veg Tokens',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await Firestore().createToken(int.parse(non.text), "non");
                            non.clear();
                          },
                          child: const Text("Add"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<TokenNotifier>(context, listen: false).refreshTokens();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Refresh  '), Icon(Icons.refresh)],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildTokenInfoCard(String title, int count) {
    return Expanded(
      flex: 1,
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("$count"),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildUserManagementCard() {
    return Card(
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
            child: DropdownButton<String>(
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
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: '2',
                  child: Row(
                    children: [
                      Text('Employee'),
                      Spacer(),
                      Icon(Icons.arrow_forward),
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
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: DropdownButton<String>(
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
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: '2',
                  child: Row(
                    children: [
                      Text('Employee'),
                      Spacer(),
                      Icon(Icons.arrow_forward),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
