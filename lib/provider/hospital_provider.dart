import 'package:flutter/material.dart';
import 'package:otschedule/model/hospital.dart';
import 'package:otschedule/services/firestore.dart';

class HospitalProvider with ChangeNotifier{

  final firestoreService = FireStore();

  String _name;
  String _id;
  List _members;
  int _numOt;

  String get name => _name;
  String get id => _id;
  List get members => _members;
  int get numOt => _numOt;

  Stream get singleHospital => firestoreService.getHospitals();

  Stream<List<Hospitals>> get hospitals => firestoreService.getHospitals();

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  set id(String value) {
    _id = value;
    notifyListeners();
  }

  set members(List value) {
    _members = value;
    notifyListeners();
  }

  set numOt(int value) {
    _numOt = value;
    notifyListeners();
  }

  loadAll(Hospitals hospital) async {
    if (hospital != null) {
      _name = hospital.name;
      _id = hospital.id;
      _members = hospital.members;
      _numOt = hospital.numOt;

    } else {
      _name = name;
      _id = id;
      _members = members;
      _numOt = numOt;
    }
  }

  loadQuery(String list) async {
    _name = name;
    _id = id;
    _members = members;
    _numOt = numOt;
  }
}