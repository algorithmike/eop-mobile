import 'package:eop_mobile/utils/gpsLocation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:eop_mobile/utils/secureStorage.dart';
import 'package:eop_mobile/utils/constants.dart';
import 'package:eop_mobile/utils/popupAlert.dart';
import 'package:eop_mobile/components/CredentialsInput.dart';

class CreateContentPage extends StatefulWidget {
  CreateContentPage({Key key, this.title, @required this.token})
      : super(key: key);

  final String title;
  final String token;

  @override
  _CreateContentPageState createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  final secureStorage = SecureStorage();
  final locator = GPSLocation();
  final TextEditingController contentTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  //TODO: Add existing event identifier to query.
  //TODO: Add customDate to query.
  final String createContent = """
            mutation CreateContent(
              \$file: Upload!,
              \$coordinates: String!,
              \$title: String!
              \$description: String
            ){
                createContent(
                    data: {
                      file: \$file,
                      coordinates: \$coordinates,
                      title: \$title,
                      description: \$description,
                      postedFromEop: true                 
                    }
                ){
                    token
                }
            }
    """;

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
            children: [
              DropdownButton<String>(
                value: 'New Event',
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 1,
                  color: kPrimaryThemeColor,
                ),
                onChanged: (String selectedValue) {
                  setState(() {
                    print(selectedValue);
                  });
                },
                //TODO: Wire up query to get list of existing events.
                items: <String>['New Event']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              CredentialsInput(
                label: 'title',
                controller: contentTitleController,
              ),
              CredentialsInput(
                label: 'description',
                controller: descriptionController,
                longText: true,
              ),
              Mutation(
                options: MutationOptions(
                  document: gql(createContent),
                  update: (GraphQLDataProxy cache, QueryResult result) async {
                    if (result.data != null) {
                      print(result.data);
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
                    onPressed: () async {
                      try {
                        Position location = await locator.getCurrentLocation();

                        popupAlert.showOkayPrompt(
                          message: location.toString(),
                        );
                        //TODO: Finish implementing file upload as commented out below.
                        // return runMutation({
                        //   'title': contentTitleController.text,
                        //   'description': descriptionController.text,
                        //   'location': location.toString()
                        // });
                      } catch (error) {
                        print('Catch block!!!');
                        print(error);
                        // popupAlert.showOkayPrompt(
                        //   message: 'Unsuccessful post.',
                        // );
                      }
                    },
                    child: Text('Publish'),
                  );
                },
              ),
              FlatButton(
                onPressed: () {
                  secureStorage.deleteAuthToken().then((result) {
                    Navigator.pop(context);
                  });
                },
                child: Text(
                  'Log out',
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
