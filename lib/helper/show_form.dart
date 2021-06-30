import 'package:flutter/material.dart';
import 'package:otschedule/pages/form.dart';

import '../model/events.dart';

void showForm(BuildContext context, Events event, DateTime date, int hour, String hospital, int numbOt, int index) {
  showModalBottomSheet(
      enableDrag: true,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(10.0))),
      context: context,
      builder: (BuildContext context){
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: EventForm(date: date, event: event, hour: hour, hospital: hospital, numbOt: numbOt, index: index,),
        );
      });
}
