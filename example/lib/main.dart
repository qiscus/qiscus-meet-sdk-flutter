
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_meet/meet_jwt_config.dart';
import 'package:qiscus_meet/qiscus_meet.dart';
import 'package:qiscus_meet/qiscus_meet_listener.dart';
import 'package:qiscus_meet/room_name_constraint.dart';
import 'package:qiscus_meet/room_name_constraint_type.dart';
import 'package:qiscus_meet/meet_info.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final roomText = TextEditingController(text: "qiscusroom");
  final subjectText = TextEditingController(text: "Qiscus Meet Example");
  final nameText = TextEditingController(text: "User1");
  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    MeetInfo.addListener(QiscusMeetListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
        onPictureInPictureTerminated: _onPictureInPictureTerminated,
        onParticipantJoined: _onParticipantJoined,
        onParticipantLeft: _onParticipantLeft,
        onRecordingStatus: _onRecordingStatus,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    MeetInfo.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(

        appBar: AppBar(
          backgroundColor: Color.fromRGBO(1, 72, 108, 1),
          title: const Text('Qiscus Meet Sample'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 24.0,
                ),
                TextField(
                  controller: roomText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Room",
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: nameText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "User Name",
                  ),
                ),
                Divider(
                  height: 48.0,
                  thickness: 2.0,
                ),
                SizedBox(
                  height: 64.0,
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () {
                      _joinMeeting();
                    },
                    child: Text(
                      "Join Meeting",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Color.fromRGBO(1, 72, 108, 1),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    QiscusMeet.setup("meetstage-iec22sd", "https://call.qiscus.com");
    MeetJwtConfig meetJwtConfig = MeetJwtConfig();
    meetJwtConfig.email = "marco@qiscus.com";
    meetJwtConfig.build();
    //Android Only
    QiscusMeet
        .config()
        .autoRecording = true;
    //iOS Only
    QiscusMeet
        .config()
        .callKitName = "Qiscus Meet:${roomText.text.toString()}";
    QiscusMeet
        .config()
        .jwtConfig = meetJwtConfig;
    QiscusMeet.config().overflowMenu = true;
    QiscusMeet.config().enableChat = false;
    QiscusMeet.config().screenSharing = true;
   QiscusMeet.call(
      //room name
        roomText.text,
        //username
        nameText.text,
        //avatar
        "https://d1.awsstatic.com/events/aws-hosted-events/2020/APAC/case-studies/case-study-logo-qiscus.5433a4b9da2693dd49766a971aac887ece8c6d18.png",
        //audio muted
        false,
        //video muted
        false)
        .build();
  }

  static final Map<RoomNameConstraintType, RoomNameConstraint>
  customContraints = {
    RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
      return value
          .trim()
          .length <= 50;
    }, "Maximum room name length should be 30."),
    RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"[$?????]+", caseSensitive: false, multiLine: false)
          .hasMatch(value) ==
          false;
    }, "Currencies characters aren't allowed in room names."),
  };

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  void _onPictureInPictureWillEnter({message}) {
    debugPrint(
        "_onPictureInPictureWillEnter broadcasted with message: $message");
  }

  void _onPictureInPictureTerminated({message}) {
    debugPrint(
        "_onPictureInPictureTerminated broadcasted with message: $message");
  }

  void _onParticipantJoined({message}) {
    //Do anything when participant joined
    debugPrint("_onParticipantJoined broadcasted with message: $message");
  }

  void _onParticipantLeft({message}) {
    //Do anything when participant left
    QiscusMeet.endCall();
    debugPrint("_onParticipantLeft broadcasted with message: $message");
  }
  void _onRecordingStatus({message}) {
    //Do anything when recording get response
    debugPrint("_onRecordingStatus message: $message");
  }

  void _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}
