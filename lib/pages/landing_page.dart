import 'package:flutter/material.dart';
import 'package:otschedule/pages/home_one.dart';
import 'package:otschedule/services/auth.dart';
import 'package:otschedule/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LandingPage extends StatelessWidget {



  /*Future getHosp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringHosp = prefs.getString('hospital');
      hosp = stringHosp;
  }*/

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    //getHosp();
    //final regUser = Provider.of<UserProvider>(context, listen: false);

    return StreamBuilder<User>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final User user = snapshot.data;
            if (user == null) {
              return SignInPage.create(context);
            }

            return HomeOne();
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}