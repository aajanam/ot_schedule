import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:otschedule/pages/landing_page.dart';
import 'package:otschedule/provider/events_provider.dart';
import 'package:otschedule/provider/hospital_provider.dart';
import 'package:otschedule/provider/userProvider.dart';
import 'package:otschedule/services/auth.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserProvider()),
        ChangeNotifierProvider(
            create: (context) => HospitalProvider()),
        ChangeNotifierProvider(
          create: (context) => EventProvider(),
        ),
        Provider<AuthBase>(
          create: (context) => Auth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LandingPage(),
      ),
    );
  }
}

