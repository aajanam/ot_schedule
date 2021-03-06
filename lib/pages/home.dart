import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
  PageController _pageController = PageController(viewportFraction: 0.94, initialPage: 0);
  DateTime _selectedDay;
  final ads = AdMobService();
  int numberOT;
  int currentPage = 0;
  String messageTitle = '';
  String messageContent = '';
  CalendarFormat format = CalendarFormat.week;

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
    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
      event.complete(event.notification);
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // Will be called whenever a notification is opened/button pressed.
    });
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
    _selectedDay = DateTime.now();

    Admob.initialize();

  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Events> loadEvent(DateTime date){
    return _groupedEvents[date] ?? [];
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
        backgroundColor: Color.fromRGBO(48, 48, 48, 1),

        actions: [
          IconButton(onPressed: () =>_confirmSignOut(context), icon: Icon(Icons.logout, color: Color.fromRGBO(227, 227, 227, 1),))],
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
            title:Transform.translate(
                offset: Offset(0,-3),
                child: Text(isDoctor == true ? 'Dr.${Auth().currentUser.displayName}': '${Auth().currentUser.displayName}', style: TextStyle(fontSize: 12),)),
            subtitle: Transform.translate(
                offset: Offset(0,-1),
                child: Text(hospital, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),)),
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
                stream: event.events(snap.data.firstWhereOrNull((element) => element.name.toLowerCase() == hospital.toString().toLowerCase()).id),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    final events = snapshot.data.toList();
                    _groupEvents(events);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TableCalendar(
                            daysOfWeekHeight: 20,
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekendStyle: TextStyle(color: Colors.pinkAccent),
                              weekdayStyle: TextStyle(color: Color.fromRGBO(227, 227, 227, 1)),
                            ),
                            calendarStyle: CalendarStyle(
                              outsideTextStyle: TextStyle(color:Colors.white38),
                              weekendTextStyle: TextStyle(color: Colors.pinkAccent)
                            ),
                            headerStyle: HeaderStyle(
                                titleTextStyle: TextStyle(color: Color.fromRGBO(1, 254, 0, 1), fontSize: 17),
                                leftChevronIcon: Icon(Icons.chevron_left, color: Color.fromRGBO(227, 227, 227, 1),),
                                rightChevronIcon: Icon(Icons.chevron_right, color: Color.fromRGBO(227, 227, 227, 1),),
                                formatButtonShowsNext: false,
                                formatButtonTextStyle: TextStyle(color: Colors.black87, fontSize: 13),
                                formatButtonDecoration: BoxDecoration( color: Color.fromRGBO(227, 227, 227, 1),borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black87)),
                                formatButtonPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                headerPadding: EdgeInsets.zero),
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            calendarFormat: format,
                            onFormatChanged: (CalendarFormat _format){
                              setState(() {
                                format = _format;
                              });
                            },
                            weekendDays: [DateTime.sunday],
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                format = CalendarFormat.week;
                              });
                            },
                            eventLoader: (date){
                              return loadEvent(date.add(Duration(hours:12)));
                            } ,

                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: _selectedDay,
                            calendarBuilders: CalendarBuilders(
                              selectedBuilder: (context, date, events) => Container(
                                  margin: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.indigo.shade400,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    date.day.toString(),
                                    style: TextStyle(color: Colors.white,),
                                  )),
                              todayBuilder: (context, date, events) => Container(
                                  margin: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.indigo.shade100.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white70)),
                                  child: Text(
                                    date.day.toString(),
                                    style: TextStyle(color: Colors.indigo.shade100.withOpacity(0.9), fontWeight: FontWeight.w600),
                                  )),
                              markerBuilder: (_, date,__,) {
                                  if (loadEvent(date.add(Duration(hours:12))).isNotEmpty) {
                                    return
                                      Positioned(
                                        top: 0,
                                        right: 1,
                                        child: Container(
                                            constraints: BoxConstraints(
                                              minWidth: 14,
                                              minHeight: 14,),
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.deepOrangeAccent),

                                            child: Text('${loadEvent(date.add(Duration(hours:12))).length}', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)),
                                      );
                                  } return null;
                              },
                            ),
                          ),
                        ),
                        //AD Here
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom:10),
                          child: Center(
                            child: AdmobBanner(
                                adUnitId: ads.getBannerAdId(),
                                adSize: AdmobBannerSize.BANNER),
                          ),
                        ),
                        Expanded(
                            child: PageView.builder(
                            controller: _pageController,
                              itemBuilder: (context, index){
                                return buildDayView(date, snapshot.data.where((element) => element.oT == '${index+1}').toList(), context, now, 60, index,);
                              },
                          itemCount: numberOT,
                          onPageChanged: (index){
                              setState(() {
                                currentPage = index;
                              });
                          },)
                        ),
                       Padding(
                         padding: const EdgeInsets.symmetric(vertical: 4.0),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             for(var i = 0; i < numberOT; i++)
                               Padding(
                                 padding: const EdgeInsets.only(right: 8.0),
                                 child: Container(
                                   height: 13, width: 13,
                                   decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                     color: i == currentPage ? Colors.lightBlueAccent : Colors.white24,
                                   ),
                                 ),
                               ),
                           ],
                         ),
                       ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text('Exit'),
            content: Text('Proceed to exit?'),
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
      content: 'Proceed logout?',
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
          hoursColumnStyle: HoursColumnStyle(
              width: columnWidth, color:
          index == 0 ? Color.fromRGBO(54, 61, 68, 1) :
          index == 1 ? Color.fromRGBO(51, 62, 61, 1) :
          Color.fromRGBO(62, 54, 63, 1),
          ),
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
                                style: TextStyle(color: Color.fromRGBO(227, 227, 227, 1) ),),
                            ),
                            //SizedBox(height: 4,),
                            Padding(
                              padding: const EdgeInsets.only(bottom:4.0),
                              child: Icon(Icons.add_sharp, color:  Color.fromRGBO(227, 227, 227, 1), size: 20,),
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
                child: Text(hour.hour >= 10 ? '${hour.hour}:00': '0${hour.hour}:00', style: TextStyle(color: Colors.white38),),
              );
          },
          dayBarStyle: DayBarStyle(
              decoration: BoxDecoration(/*border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade100.withOpacity(0.8), width: 0.5), horizontal: BorderSide.none),color:  Colors.grey.shade100.withOpacity(0.9),*/
              color: index == 0 ? color1.withOpacity(0.4) : index == 1 ? color2.withOpacity(0.4) :color3.withOpacity(0.4)),
              color: index == 0 ? color1.withOpacity(0.4) : index == 1 ? color2.withOpacity(0.4) :color3.withOpacity(0.4),
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
      bookTimeOT.add(x);
      }
    }
    bookTimeOT = bookTimeOT.toSet().toList();
  }

}
