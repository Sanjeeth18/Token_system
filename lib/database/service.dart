import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_system_connection.dart';

class Service{
  static const Root = 'http://localhost/token_system/token.php';
  static const INSERT_EGG_ACTION = "Insert_eggs";

  static Future<String> addEgg(String roll,int count) async {
    try{
      var map = Map<String,dynamic>();
      map['action'] = INSERT_EGG_ACTION;
      map['roll'] = roll;
      map['count'] = count;
      final response = await http.post(Root as Uri, body: map);
      print('Create Table Response: ${response.body}');
      if(200 == response.statusCode){
        return response.body;
      }else{
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }
}