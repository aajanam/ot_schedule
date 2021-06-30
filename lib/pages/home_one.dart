import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:otschedule/model/hospital.dart';
import 'package:otschedule/model/users.dart';
import 'package:otschedule/pages/home.dart';
import 'package:otschedule/provider/hospital_provider.dart';
import 'package:otschedule/provider/userProvider.dart';
import 'package:otschedule/services/auth.dart';
import 'package:otschedule/widget/progress_indicator.dart';
import 'package:otschedule/widget/show_alert_dialogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';


class HomeOne extends StatefulWidget {

  @override
  _HomeOneState createState() => _HomeOneState();
}

class _HomeOneState extends State<HomeOne> {

  TextEditingController _hospitalController = TextEditingController(text: '');
  TextEditingController _departmentController = TextEditingController(text: '');
  TextEditingController _nikController = TextEditingController(text: '');
  bool isDoctor = false;
  String hospital = '';
  String myNik = '';
  String myEmail = Auth().currentUser.email;
  String deviceToken;
  String myPass = '';
  String prePass = '';
  List memberOfHosp = [];
  int numOt = 1;
  List departmentList = [
    'Anesthesiology',
    'General Surgery',
    'Neurosurgery',
    'Urology',
    'Orthopedic',
    'Obs & Gyn',
    'Oral Surgery',
    'Eye Center',
    'Emergency',
    'Pediatric',
    'Intensive Care',
    'ENT',
    'OT',
    'Ward',
  ];
  Future getPlayerId () async {
    var status = await OneSignal.shared.getDeviceState();
    deviceToken = status.userId;
    return deviceToken;
  }

  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  void saveData() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    _sharePref.setString('hospital',_hospitalController.text);
    _sharePref.setBool('isDoctor', isDoctor);
    _sharePref.setString('department',_departmentController.text);
    _sharePref.setString('nik', _nikController.text);
    _sharePref.setInt('numOt', numOt);
  }

  Future loadHospital() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    return _sharePref.getString('hospital') ?? '';
  }

  Future loadDepartment() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    return _sharePref.getString('department') ?? '';
  }

  Future loadNIK() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    return _sharePref.getString('nik') ?? '';
  }

  Future loadIsDoctor() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    return _sharePref.getBool('isDoctor') ?? false;
  }

  Future loadNumOt() async {
    SharedPreferences _sharePref = await SharedPreferences.getInstance();
    return _sharePref.getInt('numOt') ?? 1;
  }

  @override
  void initState() {
    getPlayerId();
    loadHospital().then((value){
      _hospitalController.text = value;
      hospital = value;
      setState(() {});
    });
    loadIsDoctor().then((value) {
      isDoctor = value;
      setState(() {
      });
    });
    loadDepartment().then((value){
      _departmentController.text = value;
      setState(() {});
    });
    loadNIK().then((value){
      _nikController.text = value;
      myNik = value;
      prePass = '${myEmail.substring(0, myEmail.lastIndexOf('@'))}-${_nikController.text}';
      myPass = '134-$prePass';
      setState(() {});
    });
    loadNumOt().then((value){
      numOt= value;
      setState(() {});
    });


    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    _nikController.dispose();
    _departmentController.dispose();
    _hospitalController.dispose();
    // TODO: implement dispose
    super.dispose();
  }



  @override

  Widget build(BuildContext context) {
    bool isError = false;
    bool isButtonPressed = false;

    final user = Provider.of<UserProvider>(context);
    final hospitals = Provider.of<HospitalProvider>(context);
    print(deviceToken);

    return StreamBuilder<List<RegUser>>(
        stream: user.users,
        builder: (context, snapshot) {

          return StreamBuilder<List<Hospitals>>(
              stream: hospitals.hospitals,
              builder: (context, snap) {
                if(!snap.hasData){Indicator();}
                var id = snap?.data?.firstWhereOrNull((element) =>
                element.name.trim().toLowerCase() == hospital.trim().toLowerCase())?.id;

                memberOfHosp = snap?.data?.firstWhereOrNull((element) =>
                element.name.trim().toLowerCase() == hospital.trim().toLowerCase())?.members ?? [];

                numOt = snap?.data?.firstWhereOrNull((element) =>
                element.name.trim().toLowerCase() == hospital.trim().toLowerCase())?.numOt ?? 1;

                bool isIn = memberOfHosp?.contains('134-${myEmail.substring(0, myEmail.lastIndexOf('@'))}-${_nikController.text}');

                bool regHospital = snap?.data?.any((element) => element.name.trim().toLowerCase() == _hospitalController.text.trim().toLowerCase());

                return Scaffold(
                  persistentFooterButtons: [
                    Padding(
                      padding: const EdgeInsets.only(right:10.0),
                      child: regHospital == true ? TextButton.icon(
                          onPressed: (_nikController.text.isNotEmpty && isIn == false) ?  () {
                              if (!memberOfHosp.any((element) => element.toString().contains('${myEmail.substring(0, myEmail.lastIndexOf('@'))}'))) {
                                setState(() {
                                  memberOfHosp.add(prePass);
                                });
                                FirebaseFirestore.instance.collection('/hospitals').doc(id).update(
                                {
                                  'id': id,
                                  'name': hospital,
                                  'members':memberOfHosp,
                                  'numOt':numOt,
                                }
                                ).whenComplete(() => showAlertDialog(context,
                                    title: 'Thank you ${Auth().currentUser.displayName}',
                                    content: 'Please wait while we are checking your ID and come back again later.\nIf you see "GREEN CIRCLE CHECK ICON" next to your employee ID, then you are good to go',
                                    defaultActionText: 'Close'));
                              }
                              else {
                                showAlertDialog(context,
                                    title: 'Unable to register email',
                                    content: 'Your email is already registered with different Employee ID',
                                    defaultActionText: 'Close');
                                return;
                              }

                            //launch(_emailLaunchUri.toString());
                          }: null,
                          icon: Icon(Icons.mail_outline),
                          label: Text(' Register Employee ID'))
                          : TextButton.icon(
                          onPressed: () {
                            launch(_emailLaunchUri.toString());
                          },
                          icon: Icon(Icons.app_registration_sharp),
                          label: Text(' Contact Admin to Register Hospital')),
                    )
                  ],
                  appBar: AppBar(brightness: Brightness.light, elevation: 0,
                    automaticallyImplyLeading: true,
                    leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: _onPress,),),
                  body: WillPopScope(
                    onWillPop: _onPress,
                    child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 30.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom:30.0),
                                  child: Center(child: Text('Hi ${Auth().currentUser.displayName}', style: TextStyle(fontSize: 20),)),
                                ),
                                TextFormField(
                                  textCapitalization: TextCapitalization.words,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  controller: _hospitalController,
                                  onChanged: (val){
                                    isButtonPressed = false;
                                    if(isError){
                                      _formKey.currentState.validate();
                                    }
                                    setState(() {
                                      hospital=_hospitalController.text;
                                    });
                                  },

                                  validator: (str) {
                                  if (!isButtonPressed) {
                                    return null;
                                  }
                                  isError = true;
                                  if(regHospital == false) {
                                    return "$str not found";
                                  }
                                  isError = false;
                                  return null;
                                },
                                  decoration: InputDecoration(
                                    suffixIcon: regHospital == true ? Icon(Icons.check_circle_outline, color: Colors.lightGreen,size: 28,): null,
                                    isDense: true,
                                    hintText: 'Hospital',
                                    labelText: 'Hospital',
                                    labelStyle:TextStyle(fontSize: 14, color: Colors.black38) ,
                                    hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
                                    alignLabelWithHint: true,
                                    //contentPadding: EdgeInsets.only(left: 20, top:10, bottom: 3 ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.cyan), borderRadius: BorderRadius.circular(5)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blueGrey.shade200,), borderRadius: BorderRadius.circular(5)
                                    ),),
                                ),
                                SizedBox(height: 20,),
                                TextFormField(
                                  // enabled: regHospital == true ? true : false,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  controller: _nikController,
                                  onChanged: (val) {
                                    isButtonPressed = false;
                                    if(isError){
                                      _formKey.currentState.validate();
                                    }
                                    setState(() {
                                      myNik = _nikController.text;
                                      prePass = '${myEmail.substring(0, myEmail.lastIndexOf('@'))}-${_nikController.text}';
                                      myPass = '134-$prePass';
                                    });

                                    if(memberOfHosp.contains(myPass)){

                                      setState(() {isIn = true;

                                      });
                                    }

                                  },
                                   validator: (str) {
                                  if (!isButtonPressed) {
                                    return null;
                                  }
                                  isError = true;
                                  if(!memberOfHosp.contains(myPass)) {
                                    return "$str not found in $hospital";
                                  }
                                  isError = false;
                                  return null;
                                },
                                  decoration: InputDecoration(
                                    enabled: regHospital == true ? true : false,
                                    suffixIcon: isIn == true ? Icon(Icons.check_circle_outline, color: Colors.lightGreen,size: 28,) : null,
                                    isDense: true,
                                    hintText: 'Employee ID',
                                    labelText: 'Employee ID',
                                    labelStyle:TextStyle(fontSize: 14, color: Colors.black38) ,
                                    hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
                                    alignLabelWithHint: true,
                                    disabledBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blueGrey.shade100,), borderRadius: BorderRadius.circular(5)
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.cyan), borderRadius: BorderRadius.circular(5)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blueGrey.shade200,), borderRadius: BorderRadius.circular(5)
                                    ),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:5.0),
                                  child: Container(
                                    width: 200,
                                    height: 70,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("I'm a Doctor",),
                                        Switch(
                                          value: isDoctor,
                                          onChanged: (val){
                                            setState(() {
                                              isDoctor = val;
                                              user.isDoctor = val;
                                            });
                                            user.setUser();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AutoCompleteTextField(
                                  textChanged: (value){
                                    setState(() {
                                    });
                                  },

                                  itemSubmitted: (item){
                                    setState(() {
                                      _departmentController.text = item;
                                      user.department = item;
                                    });
                                  },
                                  itemSorter: (a, b){
                                    return a.compareTo(b);
                                  },
                                  itemFilter: (item, query){
                                    return item.toString().toLowerCase().startsWith(query.toLowerCase());
                                  },
                                  itemBuilder: (context, item){
                                    return SingleChildScrollView(
                                      child: Container(
                                        color: Colors.lightBlueAccent.shade100.withOpacity(0.1),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                              child: Text(item,
                                                style: TextStyle(fontSize: 17, color: Colors.black54, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  textInputAction: TextInputAction.done,
                                  clearOnSubmit: false,
                                  suggestions: departmentList,
                                  key: key,
                                  textCapitalization: TextCapitalization.words,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  controller: _departmentController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: 'Department',
                                    labelStyle:TextStyle(fontSize: 14, color: Colors.black38) ,
                                    hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
                                    alignLabelWithHint: true,
                                    //contentPadding: EdgeInsets.only(left: 20, top: 10, bottom: 0 ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.cyan), borderRadius: BorderRadius.circular(5)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blueGrey.shade200,), borderRadius: BorderRadius.circular(5)
                                    ),),
                                ),
                                Row
                                  (mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    Padding(padding: EdgeInsets.only(top: 50),
                                      child: ElevatedButton(onPressed:
                                      regHospital == true && isIn == true && departmentList.contains(_departmentController.text)? (){

                                        isButtonPressed = true;

                                        if (_formKey.currentState.validate()) {
                                          setState(() {
                                            user.deviceToken = deviceToken;
                                            user.workPlace = _hospitalController.text;
                                            user.isDoctor = isDoctor;
                                            user.department = _departmentController.text;
                                          });
                                          saveData();

                                          user.setUser();

                                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Home(numOt: numOt,)));

                                        }

                                      } : null,
                                          child: Text('Continue')),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ) ,
                );}
            /* return Indicator();*/

          );
        }
    );
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
  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ajobsku@gmail.com',
      queryParameters: {
        'subject': 'Register',
        'hospital': 'hospital',
        'Employee ID' :'Employee ID'
      }
  );
}

