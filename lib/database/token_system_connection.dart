class Egg{
  int? count;
  String? roll;
  Egg({this.roll,this.count});

  factory Egg.fromJson(Map<String , dynamic> json){
    return Egg(
      roll: json['roll_num'] as String,
      count: json['count'] as int,
    );
  }
}