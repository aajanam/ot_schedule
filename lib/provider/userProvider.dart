import 'package:flutter/material.dart';
import 'package:otschedule/model/users.dart';
import 'package:otschedule/services/auth.dart';
import 'package:otschedule/services/firestore.dart';



class UserProvider with ChangeNotifier {


  final firestoreService = FireStore();

  String _uid;
  String _displayName;
  String _email;
  String _photoUrl;
  bool _isDoctor;
  String _workPlace;
  String _specialty;


  //Getters

  String get uid => _uid;
  String get displayName => _displayName;
  String get email => _email;
  String get photoUrl => _photoUrl;
  bool get isDoctor => _isDoctor;
  String get workPlace => _workPlace;
  String get specialty => _specialty;

  Stream  singleUser(String hosp) => firestoreService.singleUser(uid, hosp);

  Stream<List<RegUser>> get users => firestoreService.getUser();


  //Setters
  set uid(String value) {
    _uid = value;
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

  set specialty(String value) {
    _specialty = value;
    notifyListeners();
  }



  //Functions
  loadAll(RegUser user) async {
    if (user != null) {
      _uid = user.uid;
      _displayName = user.displayName;
      _email = user.email;
      _photoUrl = user.photoUrl;
      _isDoctor = user.isDoctor;
      _workPlace = user.workPlace;
      _specialty = user.specialty;

    } else {
      _uid = uid;
      _displayName = displayName;
      _email = email;
      _photoUrl = photoUrl;
      _isDoctor = isDoctor;
      _workPlace = workPlace;
      _specialty = specialty;

    }
  }

  loadQuery(String list) async {
    _uid = uid;
    _displayName = displayName;
    _email = email;
    _photoUrl = photoUrl;
    _isDoctor = isDoctor;
    _workPlace = workPlace;
    _specialty = specialty;

  }

  setUser() {
    if (_uid == null) {
      //Add
      var newUser = RegUser(
          uid : Auth().currentUser.uid,
          displayName : Auth().currentUser.displayName,
          email : Auth().currentUser.email,
          photoUrl : Auth().currentUser.photoURL,
          isDoctor : _isDoctor,
          workPlace : _workPlace,
          specialty: _specialty
      );
      firestoreService.setUser(newUser, uid);
    } else {
      var editUser = RegUser(
          uid : _uid,
          displayName : _displayName,
          email : _email,
          photoUrl : _photoUrl,
          isDoctor : _isDoctor,
          workPlace : _workPlace,
          specialty : _specialty,
      );
      firestoreService.setUser(editUser, uid);

    }
  }
}
