import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:otschedule/model/events.dart';
import 'package:otschedule/services/auth.dart';
import 'package:otschedule/services/firestore.dart';
import 'package:uuid/uuid.dart';

class EventProvider with ChangeNotifier {
  final firestoreService = FireStore();

  String _eventId;
  String _creatorId;
  String _doctorId;
  DateTime _date;
  String _doctorName;
  String _diagnose;
  String _procedure;
  String _patientName;
  String _oT;
  int _startHour;
  int _endHour;
  List _bookTime;
  Timestamp _created;
  var uuid = Uuid();

  String get eventId => _eventId;
  String get creatorId => _creatorId;
  String get doctorId => _doctorId;
  DateTime get date => _date;
  String get doctorName => _doctorName;
  String get diagnose => _diagnose;
  String get procedure => _procedure;
  String get patientName => _patientName;
  String get oT => _oT;
  int get startHour => _startHour;
  int get endHour => _endHour;
  List get bookTime => _bookTime;
  Timestamp get created => _created;
  Stream<List<Events>> events(hospital) => firestoreService.getEvents(hospital);
/*  Stream<List<Events>> oT_1(hospital) => firestoreService.getOT_1(hospital);
  Stream<List<Events>> oT_2(hospital) => firestoreService.getOT_2(hospital);
  Stream<List<Events>> oT_3(hospital) => firestoreService.getOT_3(hospital);*/


  set changeDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  set changeEventId(String eventId) {
    _eventId = eventId;
    notifyListeners();
  }

  set changeCreatorId(String creatorId) {
    _creatorId = creatorId;
    notifyListeners();
  }

  set changeDoctorId(String doctorId) {
    _doctorId = doctorId;
    notifyListeners();
  }

  set changeDiagnose(String diagnose) {
    _diagnose = diagnose;
    notifyListeners();
  }

  set changeDoctorName(String doctorName) {
    _doctorName = doctorName;
    notifyListeners();
  }

  set changeProcedure(String procedure) {
    _procedure = procedure;
    notifyListeners();
  }

  set changePatientName(String patientName) {
    _patientName = patientName;
    notifyListeners();
  }

  set changeOT(String oT) {
    _oT = oT;
    notifyListeners();
  }

  set changeStartHour(int startHour) {
    _startHour = startHour;
    notifyListeners();
  }

  set changeEndHour(int endHour) {
    _endHour = endHour;
    notifyListeners();
  }
  set changeBookTime(List bookTime) {
    _bookTime = bookTime;
    notifyListeners();
  }
 set changeCreated(Timestamp created) {
    _created = created;
    notifyListeners();
  }

  loadAll(Events event) async {
    if (event != null) {
      _date = DateTime.parse(event.date);
      _doctorName = event.doctorName;
      _diagnose = event.diagnose;
      _patientName = event.patientName;
      _procedure = event.procedure;
      _endHour = event.endHour;
      _eventId = event.eventId;
      _creatorId = event.creatorId;
      _doctorId = event.doctorId;
      _startHour = event.startHour;
      _bookTime = event.bookTime;
      _oT = event.oT;
      _created = event.created;
    } else {
      _date = DateTime.now();
      _doctorName = null;
      _diagnose = null;
      _patientName = null;
      _procedure = null;
      _endHour = null;
      _eventId = null;
      _creatorId = Auth().currentUser.uid;
      _doctorId = null;
      _startHour = null;
      _bookTime = null;
      _oT = null;
      _created = Timestamp.now();
    }
  }

  saveEvent(String hospital) {
    if (_eventId == null) {
      //Add
      var newEvent = Events(
          date: _date.toIso8601String(),
          doctorName: _doctorName,
          diagnose: _diagnose,
          patientName: _patientName,
          procedure: _procedure,
          endHour: _endHour,
          startHour: _startHour,
          bookTime: _bookTime,
          oT: _oT,
          creatorId: Auth().currentUser.uid,
          doctorId: _doctorId,
          created: Timestamp.now(),
          eventId: uuid.v1());
      firestoreService.setEvent(newEvent, eventId, hospital);
    } else {
      var updateEvent = Events(
          date: _date.toIso8601String(),
          doctorName: _doctorName,
          diagnose: _diagnose,
          patientName: _patientName,
          procedure: _procedure,
          endHour: _endHour,
          startHour: _startHour,
          bookTime: _bookTime,
          oT: _oT,
          creatorId: _creatorId,
          doctorId: _doctorId,
          created: _created,
          eventId: _eventId);
      firestoreService.setEvent(updateEvent, eventId, hospital);
    }
  }
  removeEvent(String eventId, String hospital) {
    firestoreService.removeEvent(eventId, hospital);
  }
}
