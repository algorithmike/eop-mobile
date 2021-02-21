import 'package:flutter/material.dart';

import 'package:eop_mobile/components/GQLClient.dart';
import 'package:eop_mobile/pages/LoginPage.dart';

void main() {
  runApp(Eop());
}

class Eop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GQLClient(
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: LoginPage(title: 'Log In'),
      ),
    );
  }
}
