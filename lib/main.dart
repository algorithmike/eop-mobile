import 'package:flutter/material.dart';

import 'package:eop_mobile/components/GQLClient.dart';
import 'package:eop_mobile/pages/CreateContentPage.dart';
import 'package:eop_mobile/pages/LoginPage.dart';
import 'package:eop_mobile/pages/RegisterPage.dart';

import 'package:eop_mobile/utils/secureStorage.dart';

void main() {
  runApp(Eop());
}

class Eop extends StatefulWidget {
  @override
  _EopState createState() => _EopState();
}

class _EopState extends State<Eop> {
  final secureStorage = SecureStorage();

  String token;

  void getToken() async {
    token = await secureStorage.getAuthToken();
  }

  @override
  Widget build(BuildContext context) {
    getToken();
    print(token);

    return GQLClient(
      child: MaterialApp(
        theme: ThemeData.dark(),
        initialRoute: '/',
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
