import 'package:flutter/material.dart';

class PopupAlert {
  PopupAlert({@required this.context});

  final BuildContext context;

  Future<void> showOkayPrompt(
      {@required String message, String title = 'Alert'}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
