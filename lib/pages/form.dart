import 'dart:ui';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:otschedule/model/events.dart';
import 'package:otschedule/model/hospital.dart';
import 'package:otschedule/model/users.dart';
import 'package:otschedule/provider/events_provider.dart';
import 'package:otschedule/provider/hospital_provider.dart';
import 'package:otschedule/provider/userProvider.dart';
import 'package:otschedule/services/auth.dart';
import 'package:otschedule/widget/progress_indicator.dart';
import 'package:otschedule/widget/show_alert_dialogue.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class EventForm extends StatefulWidget {
  final int index;
  final int numbOt;
  final String hospital;
  final Events event;
  final DateTime date;
  final int hour;
  final List notifGroup = [];

  EventForm({this.event, this.date, this.hour, this.hospital, this.numbOt, this.index});
  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {

  DateTime selDate;
 // DateTime now = DateTime.now();

  List<String> durationList =['1'];
  List<String> oTList = [];
  int duration = 1;
  List bookTime = [];
  List availableTime = [];
  int startHour;
  int endTIme;
  String OT;
  List bookTimeAll = [];
  List<String> suggestions = [];
  String dept = '';


  final _formKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController doctorController = TextEditingController();

  List<String> playIds =[];

  Future sendMessage( playerId, messageTitle, messageBody) async {
    await OneSignal.shared.postNotification(OSCreateNotification(
        playerIds: playerId,
        content: messageBody,
        heading: messageTitle,
        sendAfter: selDate.add(Duration(hours: startHour - 2)).toUtc(),
        androidSmallIcon: 'onesignal',
      androidLargeIcon: 'onesignal_blue'
    ));
  }

  bool operator ==(dynamic other) =>
      other != null && other is EventForm && this.startHour == other.event.startHour;

  @override
  int get hashCode => super.hashCode;

  @override
  void initState() {
    if (widget.numbOt != null) {
      if (widget.event != null) {
        doctorController.text = widget.event.doctorName;
        for (var i = 1; i <= widget.numbOt; i ++ ){
          oTList.add(i.toString());
        }
      } else {
        oTList.add(widget.index.toString());
      }
    }
    final event = Provider.of<EventProvider>(context, listen: false);
    if(widget.hour != null){
      startHour = widget.hour;
    }
    if(widget.event != null){
      event.loadAll(widget.event);
        OT = widget.event.oT;
    } else {
      event.loadAll(null);
        OT = widget.index.toString();
    }

    selDate = DateTime(widget.date.year, widget.date.month, widget.date.day);
    dateController.text = formatDate(selDate,['dd',' ','M',' ', 'yyyy']);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    doctorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool drCanEdit = widget.event!= null &&  widget.event.doctorId == Auth().currentUser.uid ;
    bool youCanEdit = widget.event != null && widget.event.creatorId == Auth().currentUser.uid || widget.event == null ;
    final event = Provider.of<EventProvider>(context);
    final hosp = Provider.of<HospitalProvider>(context);
    final users = Provider.of<UserProvider>(context);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime date = DateTime(selDate.year, selDate.month, selDate.day);
    if (date.isAtSameMomentAs(today)){
      for (var i = 0; i <= HourMinute.fromDateTime(dateTime: DateTime.now()).hour; i++){
        availableTime.remove(i);
      }
    }

    InitTimeList(today);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25),
        child: StreamBuilder<List<Hospitals>>(
          stream: hosp.hospitals,
          builder: (context, snap) {
            if(snap.hasData){

              return StreamBuilder<List<Events>>(
                stream: event.events(snap.data.firstWhereOrNull((element) => element.name.toLowerCase() == widget.hospital.toLowerCase()).id),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                        getTimeList(snapshot, date);
                        getDurationLists();
                      }
                  return StreamBuilder<List<RegUser>>(
                    stream: users.users,
                    builder: (context, snp) {
                     if(snp.hasData){
                       suggestions.clear();
                       for(var i in snp?.data?.where((element) => element.isDoctor == true && element?.workPlace?.toLowerCase() == widget?.hospital?.toLowerCase())){
                        suggestions.add(i.displayName);
                       }
                     }
                      return Form(
                        key: _formKey,
                        child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: TextFormField(
                                          onTap: youCanEdit || drCanEdit  ?
                                              () async {
                                            DateTime picked = await showDatePicker(
                                                context: context,
                                                initialDate: selDate,
                                                firstDate: DateTime(2021),
                                                lastDate: DateTime(2050));
                                            if (picked != null){
                                              setState(() {
                                                selDate = picked;
                                                dateController.text = formatDate(picked,['dd',' ','M',' ', 'yy']);
                                              });
                                            }
                                          } : null,
                                          decoration: InputDecoration(
                                              labelStyle: TextStyle(color:Colors.black54),
                                              labelText: 'Date',
                                              suffixIcon:  Icon(Icons.arrow_drop_down, color:youCanEdit || drCanEdit ? Colors.black : Colors.transparent,),
                                              icon: Icon(Icons.date_range_outlined, color: widget.event != null ? Colors.lightBlue.shade700 : Colors.black54),
                                              border: InputBorder.none
                                          ),
                                          expands: false,
                                          readOnly: true,
                                          controller: dateController,
                                      ),
                                    ),
                                    Expanded(
                                        flex: 4,
                                        child: youCanEdit || drCanEdit ?  DropdownButtonFormField(
                                          isDense: true,
                                          isExpanded: false,
                                          items: oTList.map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e))).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              OT = newValue;
                                              event.changeOT = OT;
                                            });
                                            getTimeList(snapshot, date);
                                          },
                                          onSaved: (newValue){
                                            event.changeOT = OT;
                                            },
                                          value: OT,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              icon:Icon(Icons.room_outlined, color: Colors.lightBlue.shade700),
                                              labelText: 'OT Room'),
                                        ) : TextFormField(
                                          initialValue: widget.event.oT,
                                          enabled: false,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              icon:Icon(Icons.room_outlined, color: Colors.lightBlue.shade700),
                                              labelText: 'OT Room'),
                                        )
                                        )

                                  ],
                                ),
                                SizedBox(height: 12,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     Expanded(
                                          flex: 5,
                                          child:
                                       Row(
                                         children: [
                                           Icon(Icons.timer, color: Colors.cyan.shade700,),
                                           SizedBox(width: 17,),
                                           Expanded(
                                             child: Column(
                                               crossAxisAlignment:
                                               CrossAxisAlignment.start,
                                               children: [
                                                 Padding(
                                                   padding: const EdgeInsets.only(bottom: 8.0),
                                                   child: Text(
                                                     'Start Hour',
                                                     style: TextStyle(
                                                         height: 0.5,
                                                         fontSize: 12,
                                                         color: Colors.black54),
                                                   ),
                                                 ),

                                                 DropdownButton<String>(
                                                     underline: Container(),
                                                     isExpanded: true,
                                                     isDense: true,
                                                     hint: Text(startHour != null && startHour >= 10 ? '$startHour:00'
                                                         : startHour != null && startHour < 10 ? '0$startHour:00'
                                                         : '',
                                                         style: TextStyle( color: availableTime.contains(startHour) ? Colors.black : Colors.pink)),

                                                     items: youCanEdit || drCanEdit ?
                                                     availableTime.map(
                                                           (value) =>
                                                           DropdownMenuItem<
                                                               String>(
                                                             child:
                                                             Text(value >= 10 ?'$value:00' : '0$value:00', ),
                                                             value: value.toString(),
                                                           ),
                                                     )
                                                         .toList() : null,
                                                     onChanged: (value) {

                                                       setState(() {
                                                         startHour = int.parse(value);
                                                       });
                                                       getDurationLists();
                                                     }
                                                 ),
                                               ],
                                             ),
                                           ),
                                          // SizedBox(width:20),
                                         ],
                                       )
                                        ),
                                    SizedBox(width: 70,),

                                    Expanded(
                                        flex: 5,
                                        child:youCanEdit  || drCanEdit ?
                                        DropdownButtonFormField(
                                          items: youCanEdit || drCanEdit ? durationList.map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e == '1' ? '$e hour' : '$e hours'))).toList() : [],
                                          onChanged: (newValue) {

                                            setState(() {
                                              duration = int.parse(newValue);

                                            });
                                          },
                                          onSaved: (newValue){
                                            endTIme = startHour + duration;
                                            event.changeEndHour = endTIme;
                                            for (var i = 0; i < int.parse(newValue); i++){
                                              bookTime.add(startHour + i);
                                            }
                                            bookTime = bookTime.toSet().toList();
                                          },
                                          value: '$duration',
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              icon:Icon(Icons.hourglass_bottom_rounded, color: Colors.lightBlue.shade700),
                                              labelText: 'Duration'),
                                        ) : TextFormField(
                                          initialValue: '$duration hour(s)',
                                          enabled: false,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              icon:Icon(Icons.hourglass_bottom_rounded, color: Colors.lightBlue.shade700),
                                              labelText: 'Duration'),
                                        )
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                TypeAheadField(
                                  noItemsFoundBuilder: (BuildContext context) =>
                                      ListTile(
                                        title: Text('No Doctor\'s name found', style: TextStyle(color: Colors.black54),)),
                                  textFieldConfiguration: TextFieldConfiguration(
                                    onChanged: (val){
                                      setState(() {
                                        event.changeDoctorName = val;
                                      });
                                    },
                                    textCapitalization: TextCapitalization.words,
                                    controller: doctorController,
                                      decoration: InputDecoration(
                                        enabled: youCanEdit || drCanEdit ? true : false,
                                        contentPadding: EdgeInsets.zero,
                                        icon:Icon(Icons.person_outline, color: Colors.lightBlue.shade700),
                                        labelText: 'Doctor\'s name',
                                        hintStyle: TextStyle(color: Colors.black38),
                                      )
                                  ),
                                  suggestionsCallback: (pattern)  {
                                    if(doctorController.text == ''){
                                      return Iterable.empty();
                                    }
                                    return  suggestions.where((element) => element.toLowerCase().startsWith(pattern.toLowerCase()));
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    setState(() {
                                      doctorController.text = suggestion;
                                      event.changeDoctorName = suggestion;
                                    });
                                  },
                                ),
                                SizedBox(height: 18,),
                                TextFormField(
                                  maxLines: null,
                                  textCapitalization: TextCapitalization.sentences,
                                  enabled: youCanEdit || drCanEdit ? true : false,
                                  decoration:
                                  InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      icon:Icon(Icons.medical_services_outlined, color: Colors.lightBlue.shade700),
                                      labelText: 'Procedure',
                                      hintStyle: TextStyle(color: Colors.black38)),
                                  initialValue: event.procedure,
                                  onChanged: (val) =>
                                  event.changeProcedure = val,
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: 18,),
                                TextFormField(
                                  maxLines: null,
                                  textCapitalization: TextCapitalization.sentences,
                                  enabled: youCanEdit || drCanEdit ? true : false,
                                  decoration:
                                  InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      icon:Icon(Icons.analytics_outlined, color: Colors.lightBlue.shade700),
                                      labelText: 'Diagnose',
                                      hintStyle: TextStyle(color: Colors.black38)),
                                  initialValue: event.diagnose,
                                  onChanged: (val) =>
                                  event.changeDiagnose = val,
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: 18,),
                                TextFormField(
                                  textCapitalization: TextCapitalization.sentences,
                                  enabled: youCanEdit  || drCanEdit? true : false,
                                  maxLines: null,
                                  decoration:
                                  InputDecoration(icon:Icon(Icons.sick_outlined, color: Colors.lightBlue.shade700),
                                      contentPadding: EdgeInsets.zero,
                                      labelText: 'Patient\'s description / Request description',
                                      hintStyle: TextStyle(color: Colors.black38)),
                                  initialValue: event.patientName,
                                  onChanged: (val) =>
                                  event.changePatientName = val,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                ),
                                SizedBox(height: 33,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    widget.event != null && widget.event.creatorId == Auth().currentUser.uid || drCanEdit ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          primary: Colors.pink,
                                        ),
                                        onPressed:
                                            (){
                                          _confirmDelete(context, snap);
                                            },
                                        child: Text('Delete')) : Container(),
                                    SizedBox(width: 30,),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: youCanEdit  || drCanEdit ?
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          ),
                                          onPressed:
                                          availableTime.contains(startHour)? (){
                                        setState(() {
                                          _formKey.currentState.save();
                                          event.changeDate = selDate;
                                          event.changeDoctorId = snp?.data?.firstWhereOrNull((element) => element.displayName == doctorController.text)?.uid;
                                          event.changeStartHour = startHour;
                                          event.changeBookTime = bookTime;
                                          dept = snp?.data?.firstWhereOrNull((element) => element.displayName == event.doctorName)?.department;
                                        });
                                        if (dept == 'Obs & Gyn') {
                                          for (var i in snp.data.where((element) => element.department == dept || element.department == 'Pediatric')){
                                            if (i.deviceToken != null) {
                                              playIds.add(i.deviceToken.toString());
                                            }
                                          }
                                        }else{
                                          for (var i in snp.data.where((element) => element.department == dept)){
                                            if (i.deviceToken != null) {
                                              playIds.add(i.deviceToken.toString());
                                            }
                                          }
                                        }
                                        if (widget.event == null && playIds.isNotEmpty) {
                                          sendMessage(
                                              playIds,
                                              startHour >= 10 ? '${dateController.text} at $startHour:00' : '${dateController.text} at 0$startHour:00',
                                              '${event.procedure} by Dr.${event.doctorName}');
                                        }
                                        else if ((widget.event != null && widget?.event?.startHour  != startHour || widget.event != null && DateTime.parse(widget?.event?.date) != selDate) &&  playIds.isNotEmpty) {
                                          sendMessage(
                                              playIds,
                                              startHour >= 10 ? '${dateController.text} at $startHour:00' : '${dateController.text} at 0$startHour:00',
                                              '${event.procedure} by Dr.${event.doctorName}');
                                        }

                                        event.saveEvent(snap.data.where((element) => element.name.toLowerCase() == widget.hospital.toLowerCase()).first.id);

                                        Navigator.of(context).pop();
                                      } : null,
                                          child: Text('Save')) : Container(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20,),

                                widget.event != null ?
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text('Created : ${formatDate(widget.event.created.toDate(),['dd',' ','M',' ','yyyy','  at ','HH',':','nn'])}',
                                          style: TextStyle(fontSize: 12, color: Colors.black38),textAlign: TextAlign.left,),
                                    ),
                                  ],
                                )
                                    : Container(),


                              ],
                        ),
                      );
                    }
                  );
                }
              );
            }
            return Indicator();
          }
        ),
      ),
    );
  }

  void InitTimeList(DateTime today) {
    if(selDate.isAtSameMomentAs(today)){
      availableTime = [for(var i = HourMinute.fromDateTime(dateTime: DateTime.now()).hour + 1; i < 24; i += 1) i];
    }else if (selDate.isAfter(today)){
      availableTime = [for(var i = 0; i < 24; i += 1) i];
    } else {
      availableTime = [];
    }
  }

  void getDurationLists() {
    durationList = ['1'];
    for(var i = 2; i< 5 ; i ++){
      if(availableTime.contains( startHour + i - 1 )){
        durationList.add(i.toString());
      }else {
        break;
      }
    }
    durationList = durationList.toSet().toList();
  }

  void getTimeList(AsyncSnapshot<List<Events>> snapshot, DateTime date) {
    final event = Provider.of<EventProvider>(context);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    var eventOfDay = snapshot.data.where((element) => element.oT == OT
        && DateTime.parse(element.date).isAtSameMomentAs(date)
        && element.eventId != event.eventId
        /*&& element.creatorId != Auth().currentUser.uid*/).toList();
    bookTimeAll.clear();
    availableTime.clear();
    InitTimeList(today);
    for (var i in eventOfDay){
      for(var x in i.bookTime){
        bookTimeAll.add(x);
      }
    }bookTimeAll = bookTimeAll.toSet().toList();
    for(var y in bookTimeAll){
      availableTime.remove(y);
    }
    return availableTime.sort();
  }

  Future<void> _confirmDelete(BuildContext context, AsyncSnapshot<List<Hospitals>> snapshot) async {
    final event = Provider.of<EventProvider>(context, listen: false);
    final didRequestDelete = await showAlertDialog(
      context,
      title: 'Delete Event',
      content: 'Are you sure want to delete event?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Delete',
    );
    if (didRequestDelete == true) {
      event.removeEvent(event.eventId, snapshot.data.firstWhereOrNull((element) => element.name.toLowerCase() == widget.hospital.toLowerCase()).id);
      Navigator.of(context).pop();
    }
  }
  
}
