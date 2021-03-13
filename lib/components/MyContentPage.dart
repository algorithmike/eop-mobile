import 'package:flutter/material.dart';
import 'package:eop_mobile/utils/secureStorage.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:eop_mobile/utils/constants.dart';
import 'package:eop_mobile/models/Content.dart';

class MyContentPage extends StatefulWidget {
  MyContentPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyContentPageState createState() => _MyContentPageState();
}

class _MyContentPageState extends State<MyContentPage> {
  final secureStorage = SecureStorage();
  List<Container> listOfContent = [];
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
            listOfContent = [];
            result.data['me']['content'].forEach((item) {
              listOfContent.add(
                Container(
                  child: Column(
                    children: [
                      if (item['mediaType'] == 'image')
                        Image.network(item['mediaUrl']),
                      if (item['mediaType'] == 'video')
                        Text('VIDEO PLACEHOLDER'),
                      Text(
                        item['title'],
                      ),
                    ],
                  ),
                ),
              );
            });
          }

          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                toolbarHeight: 30.0,
                title: Text(widget.title),
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      (listOfContent.isEmpty)
                          ? Container(
                              margin: EdgeInsets.all(25.0),
                              child: Text('There is no content to display.'),
                            )
                          : Column(
                              children: listOfContent,
                            ),
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
