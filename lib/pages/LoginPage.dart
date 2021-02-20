import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:eop_mobile/components/CredentialsInput.dart';
import 'package:eop_mobile/utils/secureStorage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final secureStorage = SecureStorage();
  Color primaryThemeColor = Color(0xFFFF1155);
  String eopToken;

  @override
  Widget build(BuildContext context) {
    String login = """
            mutation LogIn(\$email: String!, \$password: String!){
                login (
                    email: \$email,
                    password: \$password
                ){
                    token
                }
            }
    """;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 30.0,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/eop_logo.png'),
                backgroundColor: primaryThemeColor,
                radius: 40.0,
              ),
            ),
            CredentialsInput(
              label: 'email',
              controller: emailController,
            ),
            CredentialsInput(
              label: 'password',
              controller: passwordController,
              obscureText: true,
            ),
            Mutation(
              options: MutationOptions(
                document: gql(login),
                update: (GraphQLDataProxy cache, QueryResult result) async {
                  String token = result.data['login']['token'].toString();

                  print(token);
                  await secureStorage.setAuthToken(token);

                  return cache;
                },
                onCompleted: (dynamic resultData) {
                  // print(resultData);
                  print('Completed');
                },
                onError: (dynamic errorData) {
                  // print(resultData);
                  print('Error');
                  print(errorData);
                },
              ),
              builder: (RunMutation runMutation, QueryResult result) {
                return RaisedButton(
                  color: primaryThemeColor,
                  onPressed: () {
                    print('Log In button pressed.');

                    return runMutation({
                      'email': emailController.text, // user.test.two2@email.com
                      'password': passwordController.text // testPassword123
                    });
                  },
                  child: Text('Log In'),
                );
              },
            ),
            FlatButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text(
                'Register',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
