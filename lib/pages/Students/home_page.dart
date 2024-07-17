import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:token_system/database/firebase.dart';
import 'package:token_system/pages/Students/history_page.dart';
import 'package:token_system/pages/login_page.dart';

class HomePage extends StatefulWidget {
  final String roll;
  final List<int> tokens;

  HomePage({required this.roll, required this.tokens});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime now;
  late DateFormat formatter;
  late String formattedDate;
  late int day;
  late DateFormat dayFormat;
  late DateFormat dateFormat;
  late bool valid;

  int veg = 0;
  Color vegColor = Colors.white;
  double vegElevate = 10;
  bool? vegable;

  int nonVeg = 0;
  Color nonVegColor = Colors.white;
  double nonVegElevate = 10;
  bool? nonVegable;

  int egg = 0;
  Color eggColor = Colors.white;
  int getEgg = 0;
  double eggElevate = 10;

  late List<int> listItems = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    listItems[2] = widget.tokens[2];
    initializeDate();
  }

  void initializeDate() {
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
    dayFormat = DateFormat('EEEE');
    dateFormat = DateFormat('dd-MM-yyyy');
    formattedDate = formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    vegable = (listItems[0] == 0);
    nonVegable = (listItems[1] == 0);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.restaurant_menu,
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration:const  BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff000428), Color(0xff004e92)],
            ),
          ),
        ),
        title: const Text(
          'Hostel Mess Token',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LockScreen()));
            },
            icon:const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            tooltip: "Log out",
          )
        ],
      ),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)]),
          ),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              const Divider(
                color: Colors.blueGrey,
              ),
              Card(
                color: Colors.transparent,
                elevation: nonVegElevate,
                child: ListTile(
                  leading: const Icon(
                    Icons.kebab_dining,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Non-veg',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Chicken \n Date: ${dateFormat.format(now)}\n Day: ${dayFormat.format(now)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    color: nonVegColor,
                    onPressed: () {
                      setState(() {
                        if (nonVeg == 1) {
                          nonVeg = 0;
                          nonVegElevate = 10;
                          nonVegColor = Colors.white;
                          listItems[0] = 0;
                        } else {
                          nonVeg = 1;
                          nonVegElevate = 30;
                          nonVegColor = Colors.green;
                          listItems[0] = 1;
                        }
                      });
                    },
                  ),
                ),
              ),
              const Divider(
                height: 30,
                color: Colors.blueGrey,
              ),
              Card(
                color: Colors.transparent,
                elevation: vegElevate,
                child: ListTile(
                  leading: const Icon(
                    Icons.soup_kitchen,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Veg',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Cauliflower \n Date: ${dateFormat.format(now)}\n Day: ${dayFormat.format(now)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    color: vegColor,
                    onPressed: () {
                      setState(() {
                        if (veg == 1) {
                          veg = 0;
                          vegElevate = 10;
                          vegColor = Colors.white;
                          listItems[1] = 0;
                        } else {
                          veg = 1;
                          vegElevate = 30;
                          vegColor = Colors.green;
                          listItems[1] = 1;
                        }
                      });
                    },
                  ),
                ),
              ),
              const Divider(
                height: 30,
                color: Colors.blueGrey,
              ),
              Card(
                color: Colors.transparent,
                elevation: eggElevate,
                child: ListTile(
                  leading: const Icon(
                    Icons.egg,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Egg',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            egg += 15;
                            eggColor = egg > 0 ? Colors.green : Colors.white;
                          });
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 25,
                        height: 25,
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: Text(
                          '$egg',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            egg = (egg != 0) ? egg - 15 : 0;
                            eggColor = egg > 0 ? Colors.green : Colors.white;
                          });
                        },
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    color: eggColor,
                    onPressed: () {
                      setState(() {
                        if (getEgg == 1) {
                          getEgg = 0;
                        } else {
                          getEgg = 1;
                          listItems[2] = listItems[2] + egg;
                          eggColor = egg > 0 ? Colors.green : Colors.white;
                        }
                      });
                    },
                  ),
                ),
              ),
              const Divider(
                height: 30,
                color: Colors.blueGrey,
              ),
              Card(
                color: Colors.transparent,
                child: Column(
                  children: [
                    const Text(
                      "\nYour token can be altered only before",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        listItems = await Firestore().checkAndInsertTokenData(
                            context,listItems, widget.roll, true);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return FavoritePage(
                            purchased: listItems,
                            roll: widget.roll,
                            eggcount: listItems[2],
                          );
                        }));
                      },
                      child: const Text("Purchase"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration:const  BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)]),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.primary),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    iconSize: 50,
                    tooltip: 'home',
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoritePage(
                                    purchased: widget.tokens,
                                    roll: widget.roll,
                                    eggcount: widget.tokens[2],
                                  )));
                    },
                    iconSize: 50,
                    tooltip: 'added list',
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
