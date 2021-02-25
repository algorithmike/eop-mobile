import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:eop_mobile/utils/secureStorage.dart';
import 'package:eop_mobile/utils/popupAlert.dart';
import 'package:eop_mobile/utils/constants.dart';
import 'package:eop_mobile/components/CredentialsInput.dart';
import 'package:eop_mobile/pages/CreateContentPage.dart';
import 'package:eop_mobile/pages/RegisterPage.dart';

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
  final String login = """
            mutation LogIn(\$email: String!, \$password: String!){
                login (
                    email: \$email,
                    password: \$password
                ){
                    token
                }
            }
    """;

  @override
  void initState() {
    secureStorage.getAuthToken().then((token) {
      if (token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return CreateContentPage(title: 'Create Content', token: token);
          }),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PopupAlert popupAlert = PopupAlert(context: context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 30.0,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/eop_logo.png'),
                  backgroundColor: kPrimaryThemeColor,
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
                    if (result.isLoading) {
                      return Text('...loading');
                    }

                    if (result.data != null) {
                      String token = result.data['login']['token'].toString();

                      await secureStorage.setAuthToken(token);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return CreateContentPage(
                              title: 'Create Content', token: token);
                        }),
                      );
                    } else {
                      popupAlert.showOkayPrompt(
                        message: result.exception.graphqlErrors[0].message,
                      );
                    }
                  },
                ),
                builder: (RunMutation runMutation, QueryResult result) {
                  return RaisedButton(
                    color: kPrimaryThemeColor,
                    onPressed: () {
                      return runMutation({
                        'email':
                            emailController.text, // user.test.two2@email.com
                        'password': passwordController.text // testPassword123
                      });
                    },
                    child: Text('Log In'),
                  );
                },
              ),
              FlatButton(
                onPressed: () async {
                  dynamic token = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return RegisterPage(title: 'Register');
                    }),
                  );

                  if (token != null) {
                    await secureStorage.setAuthToken(token);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return CreateContentPage(
                            title: 'Create Content', token: token);
                      }),
                    );
                  }
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
      ),
    );
  }
}
