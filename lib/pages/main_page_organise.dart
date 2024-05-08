import 'package:flutter/material.dart';
import 'package:token_system/pages/home_page.dart';
import 'package:token_system/pages/history_page.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  var selectedIndex=0;
  @override
  Widget build(BuildContext context) {
    //var appState=context.watch<DatabaseHelper>();


    Widget page=HomePage();

    switch (selectedIndex){
      case 0:
        page=HomePage();
        break;
      case 1:
        page=FavoritePage();
        break;
      default:
        print("error while shifting pages");
    }

    return Container(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.restaurant_menu,color: Colors.white,),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff000428),
                  Color(0xff004e92)
                ],
              ),
            ),
          ),
          title: const Text(
            'Hostal Mess Token',
            style: TextStyle(
              color: Colors.white,
              fontSize:20
            ),
          ),
          actions: <Widget> [
            IconButton(
                onPressed: (){
                  Navigator.pop(context);
                  },
                icon: Icon(Icons.logout,color: Colors.red,),
                tooltip: "Log out",
            )
          ],
        ),
        body:AnimatedSwitcher(
          duration: Duration(milliseconds: 0),
          child: page,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient:LinearGradient(
              colors: [
                Color(0xff000428),
                Color(0xff004e92)]
            ),
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
                      onPressed:(){
                        setState(() {
                          selectedIndex=0;
                        });
                      },
                      iconSize: 50,
                      tooltip: 'home',
                      icon: const Icon(Icons.home,color: Colors.white,),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: (){
                        setState(() {
                          selectedIndex=1;
                        });
                      },
                      iconSize: 50,
                      tooltip: 'added list',
                      icon: const Icon(Icons.shopping_cart,color: Colors.white,),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


