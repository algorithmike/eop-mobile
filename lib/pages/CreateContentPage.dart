import 'dart:io';
import 'dart:typed_data';

import 'package:eop_mobile/utils/gpsLocation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import "package:http/http.dart";
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import 'package:eop_mobile/components/CredentialsInput.dart';
import 'package:eop_mobile/components/VideoPlayerWidget.dart';
import 'package:eop_mobile/utils/enums.dart';
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

  final secureStorage = SecureStorage();
  final locator = GPSLocation();
  final TextEditingController contentTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  //TODO: (MEDIUM) Add existing event identifier to query.
  //TODO: (LOW) Add customDate to query.
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
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: DropdownButton<String>(
                  iconEnabledColor: kPrimaryThemeColor,
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
              ),
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
                    : VideoPlayerWidget(file: contentFile)
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
                label: 'title',
                controller: contentTitleController,
              ),
              CredentialsInput(
                label: 'description',
                controller: descriptionController,
                longText: true,
              ),
              if (contentFile != null)
                Mutation(
                  options: MutationOptions(
                    document: gql(createContent),
                    update: (GraphQLDataProxy cache, QueryResult result) async {
                      if (result.data != null) {
                        print('Successful Upload!');
                        print(result.data);
                        //TODO: Add post-upload navigation or actions.
                      } else {
                        print('ERROR: ');
                        print(result);
                        // popupAlert.showOkayPrompt(
                        //   message: result.exception.graphqlErrors[0].message,
                        // );
                      }
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult result) {
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

                          //TODO: Add Loading screen or something for this.
                          return runMutation({
                            'title': contentTitleController.text,
                            'description': descriptionController.text,
                            'coordinates': location.toString(),
                            'file': uploadableFile
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
                )
              else
                FlatButton(
                  onPressed: () {
                    setState(() {
                      contentFile = null;
                    });
                  },
                  child: Text(
                    'reset',
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
