import 'package:flutter/material.dart';
import 'package:otschedule/model/users.dart';
import 'package:otschedule/services/auth.dart';
import 'package:otschedule/services/firestore.dart';



class UserProvider with ChangeNotifier {


  final firestoreService = FireStore();

  String _uid;
  String _deviceToken;
  String _displayName;
  String _email;
  String _photoUrl;
  bool _isDoctor;
  String _workPlace;
  String _department;


  //Getters

  String get uid => _uid;
  String get deviceToken => _deviceToken;
  String get displayName => _displayName;
  String get email => _email;
  String get photoUrl => _photoUrl;
  bool get isDoctor => _isDoctor;
  String get workPlace => _workPlace;
  String get department => _department;

  Stream  singleUser(String hosp) => firestoreService.singleUser(uid, hosp);

  Stream<List<RegUser>> get users => firestoreService.getUser();


  //Setters
  set uid(String value) {
    _uid = value;
    notifyListeners();
  }

  set deviceToken(String value) {
    _deviceToken = value;
    notifyListeners();
  }

  set displayName(String value) {
    _displayName = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set photoUrl(String value) {
    _photoUrl = value;
    notifyListeners();
  }

  set isDoctor(bool value) {
    _isDoctor = value;
    notifyListeners();
  }

  set workPlace(String value) {
    _workPlace = value;
    notifyListeners();
  }

  set department(String value) {
    _department = value;
    notifyListeners();
  }



  //Functions
  loadAll(RegUser user) async {
    if (user != null) {
      _uid = user.uid;
      _deviceToken = user.deviceToken;
      _displayName = user.displayName;
      _email = user.email;
      _photoUrl = user.photoUrl;
      _isDoctor = user.isDoctor;
      _workPlace = user.workPlace;
      _department = user.department;

    } else {
      _uid = uid;
      _deviceToken = deviceToken;
      _displayName = displayName;
      _email = email;
      _photoUrl = photoUrl;
      _isDoctor = isDoctor;
      _workPlace = workPlace;
      _department = department;

    }
  }

  loadQuery(String list) async {
    _uid = uid;
    _deviceToken = deviceToken;
    _displayName = displayName;
    _email = email;
    _photoUrl = photoUrl;
    _isDoctor = isDoctor;
    _workPlace = workPlace;
    _department = department;

  }

  setUser() {
    if (_uid == null) {
     // getPlayerId();
      //Add
      var newUser = RegUser(
          uid : Auth().currentUser.uid,
          deviceToken : _deviceToken,
          displayName : Auth().currentUser.displayName,
          email : Auth().currentUser.email,
          photoUrl : Auth().currentUser.photoURL,
          isDoctor : _isDoctor,
          workPlace : _workPlace,
          department: _department
      );
      firestoreService.setUser(newUser, uid);
    } else {
     // getPlayerId();
      var editUser = RegUser(
          uid : _uid,
          deviceToken : _deviceToken,
          displayName : _displayName,
          email : _email,
          photoUrl : _photoUrl,
          isDoctor : _isDoctor,
          workPlace : _workPlace,
          department : _department,
      );
      firestoreService.setUser(editUser, uid);
    }
  }
  /*Future getToken () async {
    await FirebaseMessaging.instance.getToken().then((value) => deviceToken = value);
    return deviceToken;
  }
  Future getPlayerId () async {
    var status = await OneSignal.shared.getDeviceState();
    deviceToken = status.userId;
    return deviceToken;
  }*/
}
