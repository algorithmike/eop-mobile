import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:eop_mobile/components/CredentialsInput.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final String register = """
            mutation Register(
              \$email: String!,
              \$password: String!,
              \$username: String!
            ){
                createUser(
                    data: {
                      email: \$email,
                      password: \$password,
                      username: \$username
                    }
                ){
                    token
                }
            }
    """;

  void _register() {
    print('Register button pushed.');
  }

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CredentialsInput(label: 'username', controller: userNameController),
            CredentialsInput(label: 'email', controller: emailController),
            CredentialsInput(label: 'password', controller: passwordController),
            CredentialsInput(
                label: 'confirm password',
                controller: confirmPasswordController),
            Mutation(
              options: MutationOptions(
                document: gql(register),
                update: (GraphQLDataProxy cache, QueryResult result) {
                  if (result.data != null) {
                    print(result.data);
                    String token =
                        result.data['createUser']['token'].toString();

                    print('Register successful');
                    Navigator.pop(context, token);
                  } else {
                    print('Unable to register.');
                  }
                },
              ),
              builder: (RunMutation runMutation, QueryResult result) {
                return RaisedButton(
                  onPressed: () {
                    print('Log In button pressed.');
                    if (passwordController.text ==
                        confirmPasswordController.text) {
                      return runMutation({
                        'email':
                            emailController.text, // user.test.two2@email.com
                        'password': passwordController.text, // testPassword123
                        'username': userNameController.text
                      });
                    }

                    print('Passwords don\'t match');
                  },
                  child: Text('Register'),
                );
              },
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Already registered? Log in.',
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
