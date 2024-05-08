import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class FavoritePage extends StatefulWidget{
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  var purchased=[1,0,20];
  late var now;
  late var formatter;
  late String formattedDate;
  late var day;

  @override
  Widget build(BuildContext context){
    now=DateTime.now();
    day=now.toUtc().weekday;
    if(day == 5 || day==2 || day==4 || day==7){
      now=now.add(Duration(days: 2));
    }else if(day==1 || day==3 || day==6){
      now=now.add(Duration(days: 1));
    }
    formatter=DateFormat("dd-MM-yyyy\n(EEEE)");
    formattedDate=formatter.format(now);
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff000428),Color(0xff004e92)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            if(purchased[0]==1)
              Card(
                color: Colors.transparent,
                elevation: 30,
                child: ListTile(
                  tileColor: Colors.transparent,
                  leading: const Icon(Icons.kebab_dining,color: Colors.white,),
                  title: Text("Non-veg",style: TextStyle(color: Colors.white,),),
                  subtitle: Text(formattedDate,style: TextStyle(color: Colors.white,)),
                  trailing: IconButton(
                    onPressed: (){
                      Navigator.pushNamed(context, "/useNV");
                    },
                    tooltip: "Use it",
                    icon:Icon(Icons.arrow_forward_ios),
                    color: Colors.white,
                  ),
                ),
              ),
            if(purchased[0]==1)
              Divider(
                height: 20.0,
              ),
            if(purchased[1]==1)
              Card(
                elevation: 30,
                color: Colors.transparent,
                child: ListTile(
                  tileColor: Colors.transparent,
                  leading: Icon(Icons.soup_kitchen,color: Colors.white,),
                  title: Text("Veg",style: TextStyle(color: Colors.white,)),
                  subtitle: Text(formattedDate,style: TextStyle(color: Colors.white,)),
                  trailing: IconButton(
                    onPressed: (){
                      Navigator.pushNamed(context, '/useV');
                    },
                    tooltip: "Use it",
                    icon:Icon(Icons.arrow_forward_ios),
                    color: Colors.white,
                  ),
                ),
              ),
            if(purchased[1]==1)
              Divider(
                height: 20.0,
              ),
            if(purchased[2]>0)
              Card(
                elevation: 30,
                color: Colors.transparent,
                child: ListTile(
                  tileColor: Colors.transparent,
                  leading: Icon(Icons.egg,color: Colors.white,),
                  title: Text("Egg",style: TextStyle(color: Colors.white,)),
                  subtitle: Text("${purchased[2]}",style: TextStyle(color: Colors.white,)),
                  trailing: IconButton(
                    onPressed: (){
                      Navigator.pushNamed(context, '/useE');
                    },
                    tooltip: "Use it",
                    icon:Icon(Icons.arrow_forward_ios),
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}