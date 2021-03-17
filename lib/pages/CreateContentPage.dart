import 'dart:io';
import 'dart:typed_data';

import 'package:eop_mobile/components/ChewiePlayer.dart';
import 'package:eop_mobile/pages/MyContentPage.dart';
import 'package:eop_mobile/utils/gpsLocation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import "package:http/http.dart";
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import 'package:eop_mobile/components/CredentialsInput.dart';
import 'package:eop_mobile/models/enums.dart';
import 'package:eop_mobile/models/OrganizedEvent.dart';
import 'package:eop_mobile/utils/secureStorage.dart';
import 'package:eop_mobile/utils/constants.dart';
import 'package:eop_mobile/utils/popupAlert.dart';

class CreateContentPage extends StatefulWidget {
  CreateContentPage({Key key, this.title, @required this.token})
      : super(key: key);

  final String title;
  final String token;

  @override
  _CreateContentPageState createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  File contentFile;
  EopMediaType contentFileMediaType;
  String eventValue = 'new';
  bool isNewEvent = true;

  final secureStorage = SecureStorage();
  final locator = GPSLocation();
  final TextEditingController contentTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();

  void resetState() {
    setState(() {
      contentFile = null;
      contentFileMediaType = null;
      eventValue = 'new';
      isNewEvent = true;
      contentTitleController.clear();
      descriptionController.clear();
      eventTitleController.clear();
      eventDescriptionController.clear();
    });
  }

  final String myEvents = """
      query {
        me {
          eventsOrganized {
            id
            title
            description
          }
        }
      }
    """;

  final String createContent = """
    mutation CreateContent(
      \$file: Upload!,
      \$coordinates: String!,
      \$title: String!,
      \$description: String,
      \$eventId: String
      \$eventTitle: String,
      \$eventDescription: String
    ){
      createContent(
        data: {
          file: \$file,
          coordinates: \$coordinates,
          title: \$title,
          description: \$description,
          eventId: \$eventId,
          postedFromEop: true                 
        },
        newEventData: {
          title: \$eventTitle,
          description: \$eventDescription
        }
      ){
        title
        mediaUrl
      }
    }
  """;

  Future capture(EopMediaType currentMediaType) async {
    final media = (currentMediaType == EopMediaType.IMAGE)
        ? await ImagePicker().getImage(source: ImageSource.camera)
        : await ImagePicker().getVideo(source: ImageSource.camera);
    final file = File(media.path);

    if (file == null) {
      return;
    } else {
      setState(() {
        contentFile = file;
        contentFileMediaType = currentMediaType;
      });
    }
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
            children: [
              if (contentFile != null)
                (contentFileMediaType == EopMediaType.IMAGE)
                    ? SizedBox(
                        height: 300.0,
                        child: Container(
                          child: (contentFile == null)
                              ? Icon(Icons.photo, size: 100.0)
                              : Image.file(contentFile),
                          margin: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: kPrimaryThemeColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      )
                    // : VideoPlayerWidget(file: contentFile)
                    : ChewiePlayer(file: contentFile)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(20.0),
                      child: CircleAvatar(
                        radius: 30.0,
                        child: IconButton(
                          iconSize: 40.0,
                          color: kPrimaryThemeColor,
                          icon: Icon(Icons.camera_alt),
                          onPressed: () => capture(EopMediaType.IMAGE),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(20.0),
                      child: CircleAvatar(
                        radius: 30.0,
                        child: IconButton(
                          iconSize: 40.0,
                          color: kPrimaryThemeColor,
                          icon: Icon(Icons.videocam),
                          onPressed: () => capture(EopMediaType.VIDEO),
                        ),
                      ),
                    ),
                  ],
                ),
              CredentialsInput(
                label: 'content title',
                controller: contentTitleController,
              ),
              CredentialsInput(
                label: 'content description',
                controller: descriptionController,
                longText: true,
              ),
              Query(
                options: QueryOptions(
                  document: gql(myEvents),
                ),
                builder: (QueryResult result,
                    {VoidCallback refetch, FetchMore fetchMore}) {
                  if (result.hasException) {
                    // return Text(result.exception.toString());
                    print(result.exception);
                  }

                  if (result.isLoading) {
                    return LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kPrimaryThemeColor),
                    );
                  }

                  var listOfEvents = <OrganizedEvent>[
                    OrganizedEvent(id: 'new', title: 'New Event')
                  ];

                  if (result.data != null) {
                    result.data['me']['eventsOrganized'].forEach((element) {
                      print(element);
                      listOfEvents.add(
                        OrganizedEvent(
                          title: element['title'],
                          id: element['id'],
                        ),
                      );
                    });
                  }
                  var menuItems = listOfEvents.map((event) => DropdownMenuItem(
                      value: event.id, child: Text(event.title)));

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 45),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      iconEnabledColor: kPrimaryThemeColor,
                      //TODO: Setup value for query
                      value: eventValue,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: kPrimaryThemeColor)),
                        height: 1,
                      ),
                      onChanged: (String selectedValue) {
                        setState(() {
                          eventValue = selectedValue;
                          isNewEvent = (selectedValue == 'new');
                        });
                      },
                      items: menuItems.toList(),
                    ),
                  );
                },
              ),
              if (isNewEvent)
                Column(children: [
                  CredentialsInput(
                    label: 'event title',
                    controller: eventTitleController,
                  ),
                  CredentialsInput(
                    label: 'event description',
                    controller: eventDescriptionController,
                    longText: true,
                  ),
                ]),
              if (contentFile != null)
                Mutation(
                  options: MutationOptions(
                    document: gql(createContent),
                    update: (GraphQLDataProxy cache, QueryResult result) async {
                      if (result.data != null) {
                        print('Successful Upload!');
                        print(result.data);
                        resetState();
                        //TODO: Add post-upload navigation or actions.
                      } else {
                        print('ERROR: ');
                        print(result);
                      }
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult result) {
                    if (result.isLoading) {
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kPrimaryThemeColor),
                      );
                    }

                    return RaisedButton(
                      color: kPrimaryThemeColor,
                      onPressed: () async {
                        try {
                          Position location =
                              await locator.getCurrentLocation();

                          Uint8List byteData = contentFile.readAsBytesSync();
                          String filename = basename(contentFile.path);
                          String fileExt = filename.split('.').last;
                          String mediaType =
                              contentFileMediaType.toString().split('.').last;

                          final uploadableFile = MultipartFile.fromBytes(
                              fileExt, byteData,
                              filename: contentFile.path,
                              contentType: MediaType(mediaType, fileExt));

                          print('eventId: ' + eventValue);
                          print('coordinates: ' + location.toString());
                          //TODO: Add Loading screen or something for this.
                          return runMutation({
                            'title': contentTitleController.text,
                            'description': descriptionController.text,
                            'coordinates': location.toString(),
                            'file': uploadableFile,
                            'eventTitle': eventTitleController.text,
                            'eventDescription': eventDescriptionController.text,
                            'eventId': eventValue
                          });
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
              RaisedButton(
                child: Text('View My Content'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return MyContentPage(title: 'My Content');
                    }),
                  );
                },
              ),
              if (contentFile == null)
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
              FlatButton(
                onPressed: () {
                  resetState();
                },
                child: Text(
                  'Reset',
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
