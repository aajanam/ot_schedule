import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otschedule/model/events.dart';
import 'package:otschedule/model/hospital.dart';
import 'package:otschedule/model/users.dart';
import 'package:otschedule/services/auth.dart';


class FireStore{
  FirebaseFirestore _db = FirebaseFirestore.instance;


  Stream<List<Events>> getEvents(String hospitalId) {
    return _db
        .collection('hospitals/$hospitalId/events/')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Events.fromJson(doc.data()))
        .toList());
  }

  Stream<List<Hospitals>> getHospitals() {
    return _db
        .collection('/hospitals')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Hospitals.fromJson(doc.data()))
        .toList());
  }

  /*Stream<List<Events>> getOT_1(String hosp) {
    return _db
        .collection('hospital/$hosp/events/')
        .where('oT', isEqualTo: 'OT-1')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Events.fromJson(doc.data()))
        .toList());
  }

  Stream<List<Events>> getOT_2(String hosp) {
    return _db
        .collection('hospital/$hosp/events/')
        .where('oT', isEqualTo: 'OT-2')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Events.fromJson(doc.data()))
        .toList());
  }

  Stream<List<Events>> getOT_3(String hosp) {
    return _db
        .collection('hospital/$hosp/events/')
        .where('oT', isEqualTo: 'OT-3')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Events.fromJson(doc.data()))
        .toList());
  }*/

  Future<void> setEvent(Events event, String eventId, String hospitalId){
    var options = SetOptions(merge:true);
    return _db
        .collection('hospitals/$hospitalId/events/')
        .doc(event.eventId)
        .set(event.toMap(), options);
  }

  Future<void> removeEvent(String eventId, String hospitalId){
    return _db
        .collection('hospitals/$hospitalId/events/')
        .doc(eventId)
        .delete();
  }
  Stream<List<RegUser>> getUser() {
    return  _db
        .collection('/users')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RegUser.fromJson(doc.data()))
        .toList());
  }

  Stream<QuerySnapshot> singleUser (uid, String hosp) {
    var uid = Auth().currentUser.uid;
    return  _db
        .collection('hospital/$hosp/users')
        .where('uid', isEqualTo: uid)
        .snapshots();

  }
  Future<void> setUser(RegUser user, String uid){
    var options = SetOptions(merge:true);
    return _db
        .collection('/users')
        .doc(user.uid)
        .set(user.toMap(), options);
  }
}