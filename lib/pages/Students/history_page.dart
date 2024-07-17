import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:token_system/pages/Students/home_page.dart';
import 'package:token_system/pages/login_page.dart';

class FavoritePage extends StatefulWidget {
  final List<int> purchased;
  final String roll;
  final int eggcount;

  const FavoritePage(
      {Key? key,
      required this.purchased,
      required this.roll,
      required this.eggcount})
      : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late var now;
  late var formatter;
  late String formattedDate;
  late var day;

  @override
  @override
  Widget build(BuildContext context) {
    now = DateTime.now();
    day = now.toUtc().weekday;
    if (day == 5 || day == 2 || day == 4 || day == 7) {
      now = now.add(const Duration(days: 2));
    } else if (day == 1 || day == 3 || day == 6) {
      now = now.add(const Duration(days: 1));
    }
    formatter = DateFormat("dd-MM-yyyy\n(EEEE)");
    formattedDate = formatter.format(now);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.restaurant_menu,
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
              
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LockScreen()));
            
            },
            icon: const Icon(
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
            gradient: LinearGradient(
              colors: [Color(0xff000428), Color(0xff004e92)],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              if (widget.purchased.isNotEmpty && widget.purchased[0] == 1)
                Card(
                  color: Colors.transparent,
                  elevation: 30,
                  child: ListTile(
                    tileColor: Colors.transparent,
                    leading: const Icon(
                      Icons.kebab_dining,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Non-veg",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/useNV",arguments: widget.roll);
                      },
                      tooltip: "Use it",
                      icon: const Icon(Icons.arrow_forward_ios),
                      color: Colors.white,
                    ),
                  ),
                ),
              if (widget.purchased.isNotEmpty && widget.purchased[0] == 1)
                const Divider(
                  height: 20.0,
                ),
              if (widget.purchased.isNotEmpty && widget.purchased[1] == 1)
                Card(
                  elevation: 30,
                  color: Colors.transparent,
                  child: ListTile(
                    tileColor: Colors.transparent,
                    leading: const Icon(
                      Icons.soup_kitchen,
                      color: Colors.white,
                    ),
                    title: const Text("Veg",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    subtitle: Text(formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/useV',arguments: widget.roll);
                      },
                      tooltip: "Use it",
                      icon: const Icon(Icons.arrow_forward_ios),
                      color: Colors.white,
                    ),
                  ),
                ),
              if (widget.purchased.isNotEmpty && widget.purchased[1] == 1)
                const Divider(
                  height: 20.0,
                ),
              if (widget.purchased.isNotEmpty && widget.purchased[2] > 0)
                Card(
                  elevation: 30,
                  color: Colors.transparent,
                  child: ListTile(
                    tileColor: Colors.transparent,
                    leading: const Icon(
                      Icons.egg,
                      color: Colors.white,
                    ),
                    title: const Text("Egg",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    subtitle: Text("${widget.purchased[2]}",
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/useE',arguments: widget.roll);
                      },
                      tooltip: "Use it",
                      icon: const Icon(Icons.arrow_forward_ios),
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
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
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(
                                  roll: widget.roll,
                                  tokens: widget.purchased)));
                    },
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
                    onPressed: () {},
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
