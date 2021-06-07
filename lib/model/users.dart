

class RegUser {

  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final bool isDoctor;
  final String workPlace;
  final String specialty;


  RegUser({
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isDoctor,
    this.workPlace,
    this.specialty,


  });

  factory RegUser.fromJson(Map<String, dynamic> json){
    return RegUser(
        uid: json['uid'],
        displayName: json['displayName'],
        email: json['email'],
        photoUrl: json['photoUrl'],
        isDoctor: json['isDoctor'],
        workPlace: json['workPlace'],
        specialty: json['specialty'],

    );
  }

  Map<String,dynamic> toMap(){
    return {
      'uid': uid,
      'displayName':displayName,
      'email':email,
      'photoUrl': photoUrl,
      'isDoctor': isDoctor,
      'workPlace': workPlace,
      'specialty': specialty,

    };
  }
}

