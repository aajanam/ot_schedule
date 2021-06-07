import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:otschedule/helper/show_form.dart';
import 'package:otschedule/model/events.dart';
import 'package:otschedule/model/hospital.dart';
import 'package:otschedule/pages/landing_page.dart';
import 'package:otschedule/provider/events_provider.dart';
import 'package:otschedule/provider/hospital_provider.dart';
import 'package:otschedule/services/admob.dart';
import 'package:otschedule/services/auth.dart';
import 'package:otschedule/widget/progress_indicator.dart';
import 'package:otschedule/widget/show_alert_dialogue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';


class Home extends StatefulWidget {
  final String title;
  final int numOt;
  final DateTime selDate;
  const Home({Key key, this.title, this.selDate, this.numOt}) : super(key: key);


  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String oTRoom ;
  String hospital = '';
  bool isDoctor = false;
  CalendarController _calendarController;
  PageController _pageController = PageController(viewportFraction: 0.94, initialPage: 0);
  DateTime _selectedDay;
  final ads = AdMobService();
  int numberOT;
  int initialPage = 0;


  int time = 6;

  List<int> bookTimeOT = [];

  Map<DateTime, List<Events>> _groupedEvents;

  _groupEvents(List<Events> events) {
    _groupedEvents = {};
    events.forEach((event) {
      DateTime date =
      DateTime.utc(DateTime.parse(event.date).year, DateTime.parse(event.date).month, DateTime.parse(event.date).day, 12);
      if (_groupedEvents[date] == null) _groupedEvents[date] = [];
      _groupedEvents[date].add(event);
    });
  }

  Future loadNumOt() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    return _sharePref.getInt('numOt') ?? 1;
  }

  Future loadHospital() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    return _sharePref.getString('hospital') ?? '';
  }

  Future loadIsDoctor() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    return _sharePref.getBool('isDoctor') ?? false;
  }


  @override
  void initState() {
    if(widget.numOt != 0){
      numberOT = widget.numOt;
    }
    else{
      numberOT = 1;
    }
    super.initState();
    loadHospital().then((value){
      hospital = value;
      setState(() {});
    });

    loadIsDoctor().then((value) {
      isDoctor = value;
      setState(() {
      });
    });
    _calendarController = CalendarController();
    _selectedDay = DateTime.now();

    Admob.initialize();

  }
  @override
  void dispose() {
    _calendarController.dispose();
   // _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    if(widget.selDate != null){_selectedDay = widget.selDate;}
    final hosp = Provider.of<HospitalProvider>(context);
    final event = Provider.of<EventProvider>(context);
    DateTime now = DateTime.now();
    DateTime date = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    return Scaffold(
      appBar: AppBar(

        actions: [
          IconButton(onPressed: () =>_confirmSignOut(context), icon: Icon(Icons.logout, color: Colors.black54,))],
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ListTile(
            leading: Transform.translate(
                offset: Offset(7, 0),
                child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(Auth().currentUser.photoURL),)),
            contentPadding: EdgeInsets.only(top: 8, left: 5 , right: 0, bottom: 0),
            title:Text(isDoctor == true ? 'Dr.${Auth().currentUser.displayName}': '${Auth().currentUser.displayName}', style: TextStyle(fontSize: 15),),
            subtitle: Text(hospital, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),),
          ),
        ),
      ),

      body: WillPopScope(
        onWillPop: _onPress,
        child: StreamBuilder<List<Hospitals>>(
          stream: hosp.hospitals,
          builder: (context, snap) {
            if(snap.hasData){
              return StreamBuilder<List<Events>>(
                stream: event.events(snap.data.firstWhereOrNull((element) => element.name == hospital.toString().toLowerCase()).id),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    final events = snapshot.data.toList();
                    _groupEvents(events);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TableCalendar(
                          rowHeight: 55,
                          calendarStyle: CalendarStyle(
                              cellMargin: EdgeInsets.zero,
                              weekdayStyle: TextStyle(fontSize: 15),
                              weekendStyle: TextStyle(fontSize: 15, color: Colors.red),
                              holidayStyle: TextStyle(fontSize: 15, color: Colors.red)
                          ),
                          headerStyle: HeaderStyle(
                              titleTextStyle: TextStyle(color: Colors.indigo.shade800, fontSize: 17),
                              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black87,),
                              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black87,),
                              formatButtonShowsNext: false,
                              formatButtonTextStyle: TextStyle(color: Colors.black87, fontSize: 13),
                              formatButtonDecoration: BoxDecoration( color: Colors.white10,borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black87)),
                              formatButtonPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                              headerPadding: EdgeInsets.zero),
                          calendarController: _calendarController,
                          initialCalendarFormat: CalendarFormat.twoWeeks,
                          events: _groupedEvents,

                          weekendDays: [DateTime.sunday],
                          onDaySelected: (DateTime day,_,__){
                            setState(() {
                              _selectedDay = _calendarController.selectedDay;
                            });
                          },
                          initialSelectedDay: DateTime.now(),
                          builders: CalendarBuilders(
                            selectedDayBuilder: (context, date, events) => Container(
                                margin: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.indigo.shade400,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  date.day.toString(),
                                  style: TextStyle(color: Colors.white,),
                                )),
                            todayDayBuilder: (context, date, events) => Container(
                                margin: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.indigo.shade100.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all()),
                                child: Text(
                                  date.day.toString(),
                                  style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
                                )),
                            markersBuilder: (_, date, _groupedEvents , __) {
                              return [
                                Positioned(
                                  top: -1,
                                  right: 0,
                                  child: Container(
                                      constraints: BoxConstraints(
                                        minWidth: 14,
                                        minHeight: 14,),
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          // borderRadius: BorderRadius.circular(7),
                                          color: Colors.deepOrangeAccent),

                                      child: Text('${_groupedEvents.length}', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)),
                                )
                              ];
                            },
                          ),
                        ),
                        //AD Here
                        Padding(
                          padding: const EdgeInsets.only(bottom:10),
                          child: Center(
                            child: AdmobBanner(
                                adUnitId: ads.getBannerAdId(),
                                adSize: AdmobBannerSize.BANNER),
                          ),
                        ),
                        Expanded(
                            child: /*PageView(
                              controller: _pageController,
                              children: [
                                for (var i=0; i< numberOT; i++)
                                  buildDayView(date, snapshot.data.where((element) => element.oT == '${i+1}').toList(), context, now, 60, i,),
                              ],
                            )*/
                          PageView.builder(
                            controller: _pageController,
                              itemBuilder: (context, index){
                                return buildDayView(date, snapshot.data.where((element) => element.oT == '${index+1}').toList(), context, now, 60, index,);
                              },
                          itemCount: numberOT,
                          onPageChanged: (index){
                              print(index);
                          },)
                        ),
                        Container(
                          height: 25,
                        )
                      ],
                    );
                  }
                  return Indicator();
                }
              );
            }
            return Indicator();
          }
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> _onPress(){
    return showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Exit'),
            content: Text('Lanjutkan keluar dari aplikasi'),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    final auth = Provider.of<AuthBase>(context, listen: false);
                    await auth.signOut();
                    Navigator.of(context).pop(true);
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Lanjutkan logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> LandingPage()));
    }
  }

  DayView buildDayView(DateTime date,List<Events> events,
      BuildContext context, DateTime now, double columnWidth, index) {

    Color color1 = Colors.blue.shade300;
    Color color2 = Colors.teal.shade300;
    Color color3 = Colors.purple.shade300;

    return
      DayView(
          initialTime: HourMinute(hour:6, minute: 50),

          hoursColumnStyle: HoursColumnStyle(width: columnWidth,),
          userZoomable: false,
          hoursColumnTimeBuilder: (style, hour) {
            getBookedTime(events, date);
            if( !date. add(Duration(hours: hour.hour)).isBefore(DateTime.now()) && !bookTimeOT.contains(hour.hour)) {
              return Padding(
                padding: const EdgeInsets.only(top:10.0, bottom: 0),
                child: Material(
                  child: InkWell(
                    splashColor: Colors.blueGrey.shade200,
                    onTap: ()
                      => showForm(context,null, _selectedDay, hour.hour, hospital, numberOT, index + 1),

                    child: Container(
                        decoration:
                        BoxDecoration(
                            border: Border.all(color:  index == 0 ? color1 : index == 1 ? color2 :color3, width: 0.5),
                            color: index == 0 ? color1.withOpacity(0.2) : index == 1 ? color2.withOpacity(0.2) : color3.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal:5.0),
                              child: Text(hour.hour >= 10 ? '${hour.hour}:00': '0${hour.hour}:00',
                                style: TextStyle(color: index == 0 ? color1 : index == 1 ? color2 :color3 ),),
                            ),
                            //SizedBox(height: 4,),
                            Padding(
                              padding: const EdgeInsets.only(bottom:4.0),
                              child: Icon(Icons.add_sharp, color:  index == 0 ? color1 : index == 1 ? color2 :color3, size: 20,),
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
                child: Text(hour.hour >= 10 ? '${hour.hour}:00': '0${hour.hour}:00', style: TextStyle(color: Colors.black38),),
              );
          },
          dayBarStyle: DayBarStyle(
              decoration: BoxDecoration(/*border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade100.withOpacity(0.8), width: 0.5), horizontal: BorderSide.none),color:  Colors.grey.shade100.withOpacity(0.9),*/
              color: index == 0 ? color1 : index == 1 ? color2 :color3),
              color: index == 0 ? color1 : index == 1 ? color2 :color3,
              textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              dateFormatter: (day, month,year) =>
              ' OT - ${index+1} on ${formatDate(date, ['dd', ' ', 'M', ' ', 'yyyy'])}'),
          date: date,
          events: events.isNotEmpty/*&& eventOfOt == true*/ ? events.map((e) =>
          FlutterWeekViewEvent(
              onTap:(){
                showForm(context, e, _selectedDay,e.startHour , hospital, numberOT, index+1);
              },

              textStyle: TextStyle(color: e.creatorId == Auth().currentUser.uid || e.doctorId == Auth().currentUser.uid ? Colors.black : Colors.brown.shade900),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: e.creatorId == Auth().currentUser.uid || e.doctorId == Auth().currentUser.uid ? Colors.amber.shade200 : Colors.brown.shade100 ,),
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              title: e.procedure,
              description: 'Doctor: ${e.doctorName}\nPatient: ${e.patientName}\nDiagnose: ${e.diagnose}',
              start: DateTime.parse(e.date).add(
                  Duration(
                      hours: e.startHour)),
              end: DateTime.parse(e.date).add(
                  Duration(
                      hours: e.endHour))
          )
          ).toList() : [],
          style: DayViewStyle(
            backgroundColor: index == 0 ? color1.withOpacity(0.1) : index == 1 ? color2.withOpacity(0.1) :color3.withOpacity(0.1),
            currentTimeCircleRadius: 0,
            //date: now,
            currentTimeCircleColor: Colors.pink,
          )
      );
  }

  void getBookedTime(List<Events> events, DateTime date) {

  var eventDay = events.where((element) => DateTime.parse(element.date).isAtSameMomentAs(date)).toList();

  bookTimeOT.clear();
    for (var i in eventDay){
     for(var x in i.bookTime){
            //print(x);
      bookTimeOT.add(x);
      }
    }
    bookTimeOT = bookTimeOT.toSet().toList();
  }

}
