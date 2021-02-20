import 'package:flutter/material.dart';

import 'package:eop_mobile/components/GQLClient.dart';
import 'package:eop_mobile/pages/CreateContentPage.dart';
import 'package:eop_mobile/pages/LoginPage.dart';
import 'package:eop_mobile/pages/RegisterPage.dart';

void main() {
  runApp(Eop());
}

class Eop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GQLClient(
      child: MaterialApp(
        theme: ThemeData.dark(),
        initialRoute: '/createContent',
        routes: {
          '/': (context) => LoginPage(title: 'Log In'),
          '/createContent': (context) =>
              CreateContentPage(title: 'Create Content'),
          '/register': (context) => RegisterPage(title: 'Register'),
        },
      ),
    );
  }
}
