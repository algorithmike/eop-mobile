import 'package:flutter/material.dart';
import 'package:eop_mobile/LoginPage.dart';

void main() {
  runApp(Eop());
}

class Eop extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(title: 'Eop'),
      },
    );
  }
}
