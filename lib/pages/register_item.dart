import 'package:flutter/material.dart';
class Register extends ChangeNotifier{
  var items=[];

  void updateList(var nonVeg,var veg,var egg){
    items=[nonVeg,veg,egg];
    print(items);
    notifyListeners();
  }
  void changeNveg(){
    if(items[0]==1){
      items[0]=0;
    }else{
      items[0]=1;
    }
    notifyListeners();
  }

  void changeVeg(){
    if(items[1]==1){
      items[1]=0;
    }else{
      items[1]=1;
    }
    notifyListeners();
  }

  void changeEeg({int egg=0}){
    items[2]=egg;
    notifyListeners();
  }

}