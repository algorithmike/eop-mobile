import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateContentPage extends StatefulWidget {
  CreateContentPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CreateContentPageState createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  // --Start GeoPosition
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }
  // --End GeoPosition

  // --Start Local Persistence
  final storage = FlutterSecureStorage();

  writeStorage() async {
    await storage.write(key: 'test', value: 'This is a test!');
    await storage.write(key: 'testTwo', value: 'This is another test!!!!!');
    Map<String, String> allValues = await storage.readAll();
    print('Write Storage');
  }

  readStorage() async {
    Map<String, String> allValues = await storage.readAll();
    print(allValues.toString());
  }
  // --End Local Persistence

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
                Position position = await _determinePosition();
                print(position);
              },
            ),
            RaisedButton(
              child: Text('Write Storage'),
              onPressed: () async {
                print('Storage Button Pressed');
                await writeStorage();
              },
            ),
            RaisedButton(
              child: Text('Read Storage'),
              onPressed: () async {
                print('Storage Button Pressed');
                await readStorage();
              },
            ),
          ],
        ),
      ),
    );
  }
}
