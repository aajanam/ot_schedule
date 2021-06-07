
import 'package:cloud_firestore/cloud_firestore.dart';

class Events{
  final String eventId;
  final String creatorId;
  final String doctorId;
  final String date;
  final String diagnose;
  final String doctorName;
  final String procedure;
  final String patientName;
  final String oT;
  final int startHour;
  final int endHour;
  final List bookTime;
  final Timestamp created;

  Events({
    this.date,
    this.diagnose,
    this.doctorName,
    this.endHour,
    this.eventId,
    this.creatorId,
    this.doctorId,
    this.oT,
    this.patientName,
    this.procedure,
    this.startHour,
    this.bookTime,
    this.created,
});

  bool operator ==(dynamic other) =>
      other != null && other is Events && this.startHour == other.startHour;

  @override
  int get hashCode => super.hashCode;


  factory Events.fromJson(Map<String, dynamic> json){
    return Events(
      date: json['date'],
      doctorName: json['doctorName'],
      diagnose: json['diagnose'],
      endHour: json['endHour'],
      eventId: json['eventId'],
      creatorId: json['creatorId'],
      doctorId: json['doctorId'],
      oT: json['oT'],
      patientName: json['patientName'],
      procedure: json['procedure'],
      startHour: json['startHour'],
      bookTime: json['bookTime'],
      created: json['created'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'date': date,
      'doctorName': doctorName,
      'diagnose': diagnose,
      'endHour': endHour,
      'eventId': eventId,
      'creatorId': creatorId,
      'doctorId': doctorId,
      'oT': oT,
      'patientName': patientName,
      'procedure': procedure,
      'startHour': startHour,
      'bookTime': bookTime,
      'created': created,
    };
  }

}