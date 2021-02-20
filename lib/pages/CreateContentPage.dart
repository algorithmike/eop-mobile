import 'package:eop_mobile/utils/gpsLocation.dart';
import 'package:flutter/material.dart';

import 'package:eop_mobile/utils/secureStorage.dart';

class CreateContentPage extends StatefulWidget {
  CreateContentPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CreateContentPageState createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  final locator = GPSLocation();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 30.0,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            RaisedButton(
              child: Text('Get Location'),
              onPressed: () async {
                print('Location Button Pressed');
                print(await locator.getCurrentLocation());
              },
            ),
          ],
        ),
      ),
    );
  }
}
