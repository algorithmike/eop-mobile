import 'package:flutter/material.dart';
import 'package:eop_mobile/utils/secureStorage.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:eop_mobile/utils/constants.dart';
import 'package:eop_mobile/components/ChewiePlayer.dart';

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

  final String deleteContent = """
    mutation DeleteContent(\$contentId: String!){
      deleteContent(contentId: \$contentId){
        id
        title
        mediaUrl
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
                  margin: EdgeInsets.only(top: 10.0, bottom: 40.0),
                  child: Column(
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryThemeColor,
                        ),
                      ),
                      if (item['mediaType'] == 'image')
                        Image.network(item['mediaUrl']),
                      if (item['mediaType'] == 'video')
                        Container(
                          child: ChewiePlayer(mediaUrl: item['mediaUrl']),
                        ),
                      Mutation(
                        options: MutationOptions(
                          document: gql(deleteContent),
                          update: (GraphQLDataProxy cache,
                              QueryResult result) async {
                            if (result.isLoading) {
                              return Text('...loading');
                            }

                            if (result.data != null) {
                              setState(() {
                                print('Deletion Success.');
                                refetch();
                              });
                            } else {
                              print('Deletion Failed.');
                            }
                          },
                        ),
                        builder: (RunMutation runMutation, QueryResult result) {
                          return RaisedButton(
                            color: kPrimaryThemeColor,
                            onPressed: () {
                              return runMutation({'contentId': item['id']});
                            },
                            child: Text('Delete'),
                          );
                        },
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
