import 'package:mysql1/mysql1.dart';

class Mysql{
  static String user='root',
                password='Server8.0.34',
                db='token_system';
  static int port=3306;

  Mysql();

  Future<MySqlConnection> getConnection() async{
    var settings=new ConnectionSettings(
      host: 'localhost',
      port:port,
      user: user,
      password: password,
      db: db
    );
    return await MySqlConnection.connect(settings);
  }
}