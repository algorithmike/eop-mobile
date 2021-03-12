import 'package:flutter/material.dart';
import 'package:eop_mobile/utils/secureStorage.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:eop_mobile/utils/constants.dart';

class MyContentPage extends StatefulWidget {
  MyContentPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyContentPageState createState() => _MyContentPageState();
}

class _MyContentPageState extends State<MyContentPage> {
  final secureStorage = SecureStorage();

  final String myContent = """
    query {
      me {
        content {
          id			
          mediaType
          title
          createdAt
          mediaUrl
          description
          event {
            id
            title
          }
        }
      }
    }
  """;

  @override
  void initState() {
    secureStorage.getAuthToken().then((token) {
      if (token != null) {
        print('You are logged in!');
      } else {
        print('You are not logged in');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Query(
        options: QueryOptions(
          document: gql(myContent),
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            print('EXCEPTION!!!!');
            print(result.exception);
          }

          if (result.isLoading) {
            return LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kPrimaryThemeColor),
            );
          }

          if (result.data != null) {
            print('GOT RESULTS!');
            print(result.data['me']['content']);
          }

          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                toolbarHeight: 30.0,
                title: Text(widget.title),
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}
