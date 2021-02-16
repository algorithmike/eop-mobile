import 'package:flutter/material.dart';

void main() {
  runApp(Eop());
}

class Eop extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: HomePage(title: 'Eop'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loggedIn = true;

  void _placeholderPrivateMethod() {
    // setState(() {
    //
    // });
    print('Camera button was pressed.');
  }

  void _logIn() {
    setState(() {
      _loggedIn = !_loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You are logged in:',
            ),
            Text(
              '$_loggedIn',
              style: Theme.of(context).textTheme.headline4,
            ),
            RaisedButton(
                onPressed: _logIn,
                child: Text(_loggedIn ? 'Log Out' : 'Log In')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _placeholderPrivateMethod,
        tooltip: 'Camera',
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
