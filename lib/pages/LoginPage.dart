import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:eop_mobile/components/CredentialsInput.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Color primaryThemeColor = Color(0xFFFF1155);

  @override
  void initState() {
    super.initState();

    print('Init state!');
  }

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      'https://eop-backend-evtm3.ondigitalocean.app/backend/',
    );

    String login = """
            mutation {
                login (
                    email: "user.test.two2@email.com",
                    password: "testPassword123"
                ){
                    token
                }
            }
    """;

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: httpLink,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: Scaffold(
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
              CredentialsInput(label: 'email'),
              CredentialsInput(label: 'password'),
              RaisedButton(
                color: primaryThemeColor,
                onPressed: () {
                  print('Log In button pressed.');
                },
                child: Text('Log In'),
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
              Query(
                options: QueryOptions(
                  document: gql(login),
                ),
                builder: (QueryResult result,
                    {VoidCallback refetch, FetchMore fetchMore}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  if (result.isLoading) {
                    return Text('...loading');
                  }

                  return Text(
                    result.data['login']['token'].toString(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
