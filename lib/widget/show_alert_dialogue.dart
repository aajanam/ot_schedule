import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> showAlertDialog(
    BuildContext context, {
      @required String title,
      @required String content,
      String cancelActionText,
      @required String defaultActionText,
    }) {
  if (!Platform.isIOS) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: TextStyle(fontSize: 18),),
        content: Text(content, style: TextStyle(fontSize: 15)),
        actions: <Widget>[
          if (cancelActionText != null)
            TextButton(
              child: Text(cancelActionText),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          TextButton(
            child: Text(defaultActionText),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        if (cancelActionText != null)
          CupertinoDialogAction(
            child: Text(cancelActionText),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        CupertinoDialogAction(
          child: Text(defaultActionText),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}