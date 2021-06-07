

class Hospitals {
  final String id;
  final String name;
  final List members;
  final int numOt;

  Hospitals({this.name, this.members, this.numOt, this.id});

  factory Hospitals.fromJson(Map<String, dynamic> json){
    return Hospitals(
      id: json['id'],
      name: json['name'],
      members: json['members'],
      numOt: json['numOt'],
    );
  }

  Map<String,dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'members':members,
      'numOt':numOt,
    };
  }
}
