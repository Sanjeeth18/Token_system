// import 'dart:async';
// import "package:mysql1/mysql1.dart" ;
// import 'package:token_system/database/dbms.dart';
// class TOK {
//
//   var db;
//   TOK(){
//     db=new Mysql();
//   }
//
//   Future<dynamic> add_student(String id,String password,String name,String course,String dob,String doj){
//     var result = db.getConnection().query('insert into student values($id,$name,$course,to_date($dob,\'dd-mm-yyyy\'),to_date($doj,\'dd-mm-yyyy\'),$password);');
//
//     return result;
//   }
//
//   Future<dynamic> ins_tot_counts(String dat,int tot_veg,int tot_non,) async {
//     final conn=await start();
//     await conn.query('''INSERT INTO tot_count (used_veg)
//         SELECT SUM(veg)
//     FROM token where date=?''',[dat]);
//
//     await conn.query('''INSERT INTO tot_count (used_non_veg)
//         SELECT SUM(non)
//     FROM token where date=?''',[dat]);
//
//     await conn.query('''insert into tot_count (not_used_veg) select sum(used_veg)
//                         from token where date=?''',[dat]);
//
//     await conn.query('''update tot_count set(not_used_veg)=tot_veg-not_used_veg
//                         where date=?''',[dat]);
//
//     await conn.query('''insert into tot_count (not_used_non_veg) select sum(used_not_veg)
//                         from token where date=?''',[dat]);
//
//     await conn.query('''update tot_count set(not_used_non_veg)=tot_non-not_used_non_veg
//                         where date=?''',[dat]);
//
//
//   }
//
//   Future<dynamic> ins_student(String num,String password) async {                                 //insert into student table
//     final conn=await start();
//     final res=await conn.query('SELECT password FROM student where roll=?',[num]);
//
//     if (res.isEmpty){
//       return 0;
//     }
//
//     else {
//       print(res);
//       return 1;
//     }
//   }
//
//   Future<dynamic> ins_egg(String num,int e) async{                                                    //insert into egg table
//     final conn=await start();
//     final res=await conn.query('SELECT * FROM student where roll=?',[num]);
//
//     if (res.isEmpty){
//       await conn.query('INSERT INTO student (roll,count) VALUES (?,?)',[num,e]);
//     }
//
//     else {
//       await conn.query('update eggs set count=? where roll=?',[e,num]);
//     }
//     return 1;
//   }
//
//
//   Future ins_token(String num,int v,int nv,int e,String dat) async{                                  //insert into token table
//     final conn=await start();
//     final res=await conn.query('select * from token where roll=?',[num]);
//
//     if(res.isEmpty) {
//       await conn.querry('insert into token (roll,veg,non,date) values(?,?,?,?)', [num, v, nv,dat]);
//     }
//
//     else{
//       await conn.query('update token set non=? , veg=? , date=? where roll=?',[nv,v,dat,num]);
//     }
//
//
//     if (e!=0){
//       ins_egg(num,e);
//     }
//     return 1;
//   }
//
//   Future<dynamic> ins_employee(String num,String password) async{                                  //insert into employee table
//     final conn=await start();
//
//     final res=await conn.query('SELECT * FROM employee where empid=?',[num]);
//
//     if (res.isEmpty){
//       return 0;
//     }
//
//     else {
//       await conn.query('update employee set pass=? where roll=?',[password,num]);
//       return 1;
//     }
//
//   }
//
//   Future <dynamic> ins_management() async{                                       //insert into management table
//     final conn=await start();
//     String num="C5386";
//     String pass="1234";
//     await conn.query('insert into management (id,pass) values(?,?)',[num,pass]);
//   }
//
//   Future<dynamic> ins_MtoS(String num,String name,String course,String dob,String doj) async{          //inserting the student basic details by management
//     final conn=await start();
//
//     final res=await conn.query('select * from student where roll=?',[num]);
//
//     if(res.isEmpty) {
//       await conn.query('insert into student (roll,sname,course,dob,yoj) values(?,?,?,?,?)', [num,name,course,dob,doj]);
//       return 1;
//     }
//
//     else{
//       return 0;
//     }
//   }
//
//   Future ins_MtoE(String id,String name,String dob,String doj) async{          //inserting the employee basic details by management
//     final conn=await start();
//
//     final res=await conn.query('select * from employee where empid=?',[num]);
//
//     if(res.isEmpty) {
//       await conn.querry('insert into employee (empid,ename,dob,doj) values(?,?,?,?)', [num,name,dob,doj]);
//       return 1;
//     }
//
//     else{
//       return 0;
//     }
//   }
//
//   Future<dynamic> read_stud(String num) async {                                   //displaying the student
//     final conn=await start();
//     return conn.query('select roll,sname,dob,yoj,extract(year from current_date)-extract(year from doj) as year from student where roll=? and  year<5',[num]);
//   }
//
//   Future<dynamic> read_emp(String num) async {                                   //displaying the employee
//     final conn=await start();
//     var res=await conn.query('select empid,ename,dob,doj,extract(year from current_date)-extract(year from doj) as experience from employee where empid=? ',[num]);
//   }
//
//
//   Future<dynamic> del_MtoS(String num) async {                                                   //deleting student data by management
//     final conn=await start();
//     final res=await conn.query('select * from student where roll=?',[num]);
//
//     if(res.isEmpty){
//       return 0;
//     }
//     else{
//       await conn.query('delete from student where roll=?',[num]);
//       return 1;
//     }
//   }
//
//   Future<dynamic> del_MtoE(String num) async {
//     //deleting student data by management
//     final conn = await start();
//     final res=await conn.query('select * from employee where empid=?',[num]);
//
//     if(res.isEmpty){
//       return 0;
//     }
//
//     else{
//       await conn.query('delete from employee where empid=?',[num]);
//       return 1;
//     }
//   }
//
//   Future<dynamic> check(String num) async{
//     final conn=await start();
//     await conn.query('delete from token where veg=0 and non=0 and roll=?',[num]);
//   }
//
// }
//
//
//
