import 'package:eop_mobile/utils/gpsLocation.dart';
import 'package:flutter/material.dart';

import 'package:eop_mobile/utils/secureStorage.dart';
import 'package:eop_mobile/components/CredentialsInput.dart';

class CreateContentPage extends StatefulWidget {
  CreateContentPage({Key key, this.title, @required this.token})
      : super(key: key);

  final String title;
  final String token;

  @override
  _CreateContentPageState createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  final locator = GPSLocation();
  final TextEditingController controller = TextEditingController();

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
            CredentialsInput(
              label: 'Test Text',
              controller: controller,
            ),
            RaisedButton(
              child: Text('Test Text Input'),
              onPressed: () async {
                print('Test Text Input Pressed');
                print(controller.text);
              },
            ),
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
