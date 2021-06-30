

class RegUser {

  final String uid;
  final String deviceToken;
  final String displayName;
  final String email;
  final String photoUrl;
  final bool isDoctor;
  final String workPlace;
  final String department;


  RegUser({
    this.uid,
    this.deviceToken,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isDoctor,
    this.workPlace,
    this.department,


  });

  factory RegUser.fromJson(Map<String, dynamic> json){
    return RegUser(
        uid: json['uid'],
        deviceToken: json['deviceToken'],
        displayName: json['displayName'],
        email: json['email'],
        photoUrl: json['photoUrl'],
        isDoctor: json['isDoctor'],
        workPlace: json['workPlace'],
        department: json['department'],

    );
  }

  Map<String,dynamic> toMap(){
    return {
      'uid': uid,
      'deviceToken': deviceToken,
      'displayName':displayName,
      'email':email,
      'photoUrl': photoUrl,
      'isDoctor': isDoctor,
      'workPlace': workPlace,
      'department': department,

    };
  }
}

