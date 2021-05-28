import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({Key key, this.title = 'There\'s an issue', @required this.content})
      : super(key: key);
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _showIOSDialog(context) : _showAndroidDialog(context);
  }

  CupertinoAlertDialog _showIOSDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        CupertinoDialogAction(
          child: const Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

    AlertDialog _showAndroidDialog(BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          FlatButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
  }
}
