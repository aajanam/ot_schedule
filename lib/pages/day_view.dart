/*
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';


import '../model/events.dart';
import '../services/auth.dart';

DayView buildDayView(DateTime date, AsyncSnapshot<List<Events>> snapshot,
    BuildContext context, DateTime now, double columnWidth, index) {
  return*/
/* WeekView(
      dates: [date],
   userZoomable: false,);*//*


  DayView(
    initialTime: HourMinute(hour:6, minute: 30),

     hoursColumnStyle: HoursColumnStyle(width: columnWidth),
      userZoomable: false,
      hoursColumnTimeBuilder: (style, hour) {
        if(!date.add(Duration(hours: hour.hour)).isBefore(DateTime.now()) && !bookTimeOT.contains(hour.hour)) {
          return Padding(
            padding: const EdgeInsets.only(top:10.0, bottom: 0),
            child: Material(
              child: InkWell(
                splashColor: Colors.blueGrey.shade200,
                onTap: () async {

                  await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EventForm(date: _selectedDay, hour: hour.hour,)))
                      .then((selectedTime) {
                    bookTimeOT.clear();

                    if (selectedTime != null) {
                      setState(() {
                        DateTime day = selectedTime['date'];
                        _calendarController.setSelectedDay( DateTime(day.year, day.month, day.day));
                        _selectedDay =  DateTime(day.year, day.month, day.day);
                        time = selectedTime['time'][0];
                        getBookedTime(snapshot,  DateTime(day.year, day.month, day.day));
                      });
                    }});
                },
                child: Container(
                    decoration:
                    BoxDecoration(
                        border: Border.all(color: Colors.teal, width: 0.5),
                        color: Colors.lightBlue.shade100.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:5.0),
                          child: Text(hour.hour >= 10 ? '${hour.hour}:00': '0${hour.hour}:00',
                            style: TextStyle(color: Colors.teal),),
                        ),
                        //SizedBox(height: 4,),
                        Padding(
                          padding: const EdgeInsets.only(bottom:4.0),
                          child: Icon(Icons.add_sharp, color: Colors.teal, size: 20,),
                        ),
                      ],
                    )),
              ),
            ),
          );
        }
        return
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Text(hour.hour >= 10 ? '${hour.hour}:00': '0${hour.hour}:00', style: TextStyle(color: Colors.black87.withOpacity(0.4)),),
          );
      },
      dayBarStyle: DayBarStyle(
          decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade400.withOpacity(0.8), width: 0.5), horizontal: BorderSide.none),color:  Colors.transparent.withOpacity(0.9),),
          color: Colors.transparent,
        textStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        dateFormatter: (day, month,year) => formatDate(date, ['dd',' ', 'M',' ', 'yyyy'])),
      date: date,
      events: snapshot.hasData ? snapshot.data.map((e) =>  new FlutterWeekViewEvent(
          onTap: e.creatorId == Auth().currentUser.uid ? (){
           // showForm(context, e, date);
          } : (){
           // buildShowInfo(context, e);
          },
          textStyle: TextStyle(color: e.creatorId == Auth().currentUser.uid ? Colors.black : Colors.white),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: e.creatorId == Auth().currentUser.uid ? Colors.amber.shade200 : Colors.teal.shade200 ,),
          margin: EdgeInsets.all(2),
          title: e.procedure,
          description: 'Dokter: ${e.doctorName}\nPasien: ${e.patientName}\nDiagnosa: ${e.diagnose}',
          start: DateTime.parse(e.date).add(
              Duration(
                  hours: e.startHour)),
          end: DateTime.parse(e.date).add(
              Duration(
                  hours: e.endHour))
      )
      ).toList() : [],
      style: DayViewStyle.fromDate(
        currentTimeCircleRadius: 0,
        date: now,
        currentTimeCircleColor: Colors.pink,
      )
  );
}
*/
