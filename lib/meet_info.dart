import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qiscus_meet/feature_flag/feature_flag.dart';
import 'package:qiscus_meet/qiscus_meet.dart';
import 'package:qiscus_meet/qiscus_response.dart';

import 'meet_config.dart';
import 'qiscus_meet_listener.dart';
import 'room_name_constraint.dart';
import 'room_name_constraint_type.dart';
import 'package:http/http.dart' as http;

class MeetInfo {
  static const MethodChannel _channel = const MethodChannel('qiscus_meet');
  static const EventChannel _eventChannel =
      const EventChannel('qiscus_meet_events');
  var displayName = "guest";
  var avatar =
      "https://d1.awsstatic.com/events/aws-hosted-events/2020/APAC/case-studies/case-study-logo-qiscus.5433a4b9da2693dd49766a971aac887ece8c6d18.png";
  var type = QiscusMeetType.VIDEO;
  var url = "https://call.qiscus.com";
  var typeCaller;
  var roomId = "";
  var audioMuted = false;
  var videooMuted = false;
  var callkit = "";
  var recordingStatus = "";
  static List<QiscusMeetListener> _listeners = <QiscusMeetListener>[];
  static Map<String, QiscusMeetListener> _perMeetingListeners = {};
  static bool _hasInitialized = false;
  MeetConfig config;
  static Map<String, String> _recordingListner = {};

  void setTypeCall(QiscusMeetType type) {}

  MeetInfo(
      String url,
      QiscusMeetTypeCaller typeCaller,
      MeetConfig config,
      String roomId,
      String displayName,
      String avatar,
      bool audioMuted,
      bool videoMuted) {
    this.url = url;
    this.typeCaller = typeCaller;
    this.config = config;
    this.roomId = roomId;
    this.displayName = displayName;
    if (avatar != null || avatar != "" || avatar != '') {
      this.avatar = avatar;
    }
    if (url != null || url != "" || url != '') {
      this.url = url;
    }

    this.avatar = avatar;
    this.callkit = config.callKitName;
    this.audioMuted = audioMuted;
    this.videooMuted = videoMuted;
  }

  void build() {
    generateToken(displayName, avatar);
  }

  static final Map<RoomNameConstraintType, RoomNameConstraint>
      defaultRoomNameConstraints = {
    RoomNameConstraintType.MIN_LENGTH: new RoomNameConstraint((value) {
      return value.trim().length >= 3;
    }, "Minimum room length is 3"),

//    RoomNameConstraintType.MAX_LENGTH : new RoomNameConstraint(
//            (value) { return value.trim().length <= 50; },
//            "Maximum room length is 50"),

    RoomNameConstraintType.ALLOWED_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"^[a-zA-Z0-9-_]+$", caseSensitive: false, multiLine: false)
          .hasMatch(value);
    }, "Only alphanumeric, dash, and underscore chars allowed"),

//    RoomNameConstraintType.FORBIDDEN_CHARS : new RoomNameConstraint(
//            (value) { return RegExp(r"[\\\/]+", caseSensitive: false, multiLine: false).hasMatch(value) == false; },
//            "Slash and anti-slash characters are forbidden"),
  };

  /// Joins a meeting based on the JitsiMeetingOptions passed in.
  /// A JitsiMeetingListener can be attached to this meeting that will automatically
  /// be removed when the meeting has ended

  Future<QiscusMeetResponse> call(
      String appId, String userName, String jwtToken, recordingResponse,
      {QiscusMeetListener listener,
      Map<RoomNameConstraintType, RoomNameConstraint>
          roomNameConstraints}) async {
    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      featureFlag.overFlowMenu = config.overflowMenu;
      featureFlag.screenSharing = config.screenSharing;
      featureFlag.chatEnabled = config.enableChat;
      featureFlag.meetingNameEnabled = config.enableRoomName;
      // Here is an example, disabling features for each platform
      if (io.Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
        featureFlag.autoRecording = config.autoRecording;
        debugPrint("AUTO RECORDING ${config.autoRecording}");
      } else if (io.Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlag.pipEnabled = false;
        featureFlag.callkitName = callkit;
      }
      var roomUrl = appId + "/" + roomId;
      var options = QiscusMeetOptions()
        ..room = roomUrl
        ..serverURL = url
        ..userDisplayName = displayName
        ..userAvatarURL = avatar != null
            ? avatar
            : "https://d1.awsstatic.com/events/aws-hosted-events/2020/APAC/case-studies/case-study-logo-qiscus.5433a4b9da2693dd49766a971aac887ece8c6d18.png"
        ..userEmail = config.jwtConfig.email
        ..audioOnly = false
        ..audioMuted = audioMuted
        ..videoMuted = videooMuted
        ..token = jwtToken
        ..featureFlag = featureFlag;
      assert(options != null, "options are null");
      assert(options.room != null, "room is null");
      assert(options.room.trim().isNotEmpty, "room is empty");

      // If no constraints given, take default ones
      // (To avoid using constraint, just give an empty Map)
      if (roomNameConstraints == null) {
        roomNameConstraints = defaultRoomNameConstraints;
      }

      // Check each constraint, if it exist
      // (To avoid using constraint, just give an empty Map)
      // if (roomNameConstraints.isNotEmpty) {
      //   for (RoomNameConstraint constraint in roomNameConstraints.values) {
      //     assert(constraint.checkConstraint(options.room),
      //         constraint.getMessage());
      //   }
      // }

      // Validate serverURL is absolute if it is not null or empty
      if (options.serverURL?.isNotEmpty ?? false) {
        assert(Uri.parse(options.serverURL).isAbsolute,
            "URL must be of the format <scheme>://<host>[/path], like https://someHost.com");
      }

      // Attach a listener if it exists. The key is based on the serverURL + room
      if (listener != null) {
        String serverURL = options.serverURL ?? "https://call.qiscus.com";
        String key;
        if (serverURL.endsWith("/")) {
          key = serverURL + options.room;
        } else {
          key = serverURL + "/" + options.room;
        }

        _perMeetingListeners.update(key, (oldListener) => listener,
            ifAbsent: () => listener);
        _initialize();
      }

      return await _channel
          .invokeMethod<String>('joinMeeting', <String, dynamic>{
            'room': options.room,
            'serverURL': options.serverURL,
            'subject': options.subject,
            'token': options.token,
            'audioMuted': options.audioMuted,
            'audioOnly': options.audioOnly,
            'videoMuted': options.videoMuted,
            'featureFlags': options.getFeatureFlags(),
            'userDisplayName': options.userDisplayName,
            'userEmail': options.userEmail,
            'userAvatarURL': options.userAvatarURL,
          })
          .then((message) =>
              QiscusMeetResponse(isSuccess: true, message: message))
          .catchError((error) {
            debugPrint("error: $error, type: ${error.runtimeType}");
            return QiscusMeetResponse(
                isSuccess: false, message: error.toString(), error: error);
          });
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  /// Initializes the event channel. Call when listeners are added
  static _initialize() {
    if (!_hasInitialized) {
      debugPrint('Qiscus Meet - initializing event channel');
      _eventChannel.receiveBroadcastStream().listen((dynamic message) {
        debugPrint('Qiscus Meet - broadcast event: $message');
        _broadcastToGlobalListeners(message);
        _broadcastToPerMeetingListeners(message);
      }, onError: (dynamic error) {
        debugPrint('Qiscus Meet broadcast error: $error');
        _listeners.forEach((listener) {
          if (listener.onError != null) listener.onError(error);
        });
        _perMeetingListeners.forEach((key, listener) {
          if (listener.onError != null) listener.onError(error);
        });
      });
      _hasInitialized = true;
    }
  }

  static endCall() {
    _channel.invokeMethod('closeMeeting');
  }

  /// Adds a QiscusMeetListner that will broadcast conference events
  static addListener(QiscusMeetListener qiscusMeetListner) {
    debugPrint('Qiscus Meet - addListener');
    _listeners.add(qiscusMeetListner);
    _initialize();
  }

  /// Sends a broadcast to global listeners added using addListener
  static void _broadcastToGlobalListeners(message) {
    _listeners.forEach((listener) {
      switch (message['event']) {
        case "onConferenceWillJoin":
          if (listener.onConferenceWillJoin != null) {
            listener.onConferenceWillJoin(message: message);
          }
          if (_recordingListner != null) {
            listener.onRecordingStatus(message: _recordingListner);
          }
          break;
        case "onConferenceJoined":
          if (listener.onConferenceJoined != null)
            listener.onConferenceJoined(message: message);
          break;
        case "onConferenceTerminated":
          if (listener.onConferenceTerminated != null)
            listener.onConferenceTerminated(message: message);
          break;
        case "onPictureInPictureWillEnter":
          if (listener.onPictureInPictureWillEnter != null)
            listener.onPictureInPictureWillEnter(message: message);
          break;
        case "onPictureInPictureTerminated":
          if (listener.onPictureInPictureTerminated != null)
            listener.onPictureInPictureTerminated(message: message);
          break;
        case "onParticipantJoined":
          if (listener.onParticipantJoined != null)
            listener.onParticipantJoined(message: message);
          break;
        case "onParticipantLeft":
          if (listener.onParticipantLeft != null)
            listener.onParticipantLeft(message: message);
          break;
      }
    });
  }

  /// Sends a broadcast to per meeting listeners added during joinMeeting
  static void _broadcastToPerMeetingListeners(message) {
    String url = message['url'];
    final listener = _perMeetingListeners[url];
    if (listener != null) {
      switch (message['event']) {
        case "onConferenceWillJoin":
          if (listener.onConferenceWillJoin != null)
            listener.onConferenceWillJoin(message: message);
          if (_recordingListner != null) {
            listener.onRecordingStatus(message: _recordingListner);
          }
          break;
        case "onConferenceJoined":
          if (listener.onConferenceJoined != null)
            listener.onConferenceJoined(message: message);
          break;
        case "onConferenceTerminated":
          if (listener.onConferenceTerminated != null)
            listener.onConferenceTerminated(message: message);

          // Remove the listener from the map of _perMeetingListeners on terminate
          _perMeetingListeners.remove(listener);
          break;
        case "onPictureInPictureWillEnter":
          if (listener.onPictureInPictureWillEnter != null)
            listener.onPictureInPictureWillEnter(message: message);
          break;
        case "onPictureInPictureTerminated":
          if (listener.onPictureInPictureTerminated != null)
            listener.onPictureInPictureTerminated(message: message);
          break;
      }
    }
  }

  /// Removes the QiscusMeetListner specified
  static removeListener(QiscusMeetListener qiscusMeetListener) {
    _listeners.remove(qiscusMeetListener);
  }

  /// Removes all QiscusMeetListner
  static removeAllListeners() {
    _listeners.clear();
  }

  Future<Void> generateToken(String name, String avatar) async {
    Map<String, Object> objectPayload = config.jwtConfig.getJwtPayload();
    if (avatar != null) {
      objectPayload['avatar'] = "$avatar";
    } else {}
    objectPayload['name'] = name;
    objectPayload['room'] = roomId;
    var uri = "$url:5050/generate_url";
    final http.Response response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer X6tMDYkJF7MVPQ32'
        },
        body: json.encode(objectPayload));
    if (response.statusCode == 200) {
      var qiscusResponse = Qiscus_response.fromJson(jsonDecode(response.body));
      var token = qiscusResponse.token;
      if (io.Platform.isAndroid) {
        if (config.autoRecording) {
          getRecordingStatus(objectPayload["app_id"], name, token);
        } else {
          call(objectPayload["app_id"], name, token, "");
        }
      } else {
        call(objectPayload["app_id"], name, token, "");
      }
    } else {
      debugPrint("TOKEN ERROR : ${response.statusCode}");
    }
  }

  Future<Void> getRecordingStatus(
      String appID, String name, String token) async {
    var uri = "$url:5050/api/recordings/$appID/status";
    final http.Response response = await http.get(uri,
        headers: <String, String>{'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      recordingStatus = jsonDecode(response.body);
      call(appID, name, token, recordingStatus);
      _recordingListner["message"] = "${response.body}";
      _recordingListner["statusCode"] = "${response.statusCode}";
      print("RECORDING STATUS:${response.body}");
    } else {
      call(appID, name, token, recordingStatus);
      _recordingListner["message"] = "${response.body}";
      _recordingListner["statusCode"] = "${response.statusCode}";
      print("RECORDING ERROR : ${response.body}");
    }
  }
}

class QiscusMeetResponse {
  final bool isSuccess;
  final String message;
  final dynamic error;

  QiscusMeetResponse({this.isSuccess, this.message, this.error});

  @override
  String toString() {
    return 'QiscusMeetResponse{isSuccess: $isSuccess, message: $message, error: $error}';
  }
}

class QiscusMeetOptions {
  String room;
  String serverURL;
  String subject;
  String token;
  bool audioMuted;
  bool audioOnly;
  bool videoMuted;
  String userDisplayName;
  String userEmail;
  String userAvatarURL;
  FeatureFlag featureFlag;

  /// Get feature flags Map with keys as String instead of Enum
  /// Useful as an argument sent to the Kotlin/Swift code
  Map<String, dynamic> getFeatureFlags() =>
      (featureFlag != null) ? featureFlag.allFeatureFlags() : new HashMap();

  @override
  String toString() {
    return 'Qiscus Meet Options{room: $room, serverURL: $serverURL, subject: $subject, token: $token, audioMuted: $audioMuted, audioOnly: $audioOnly, videoMuted: $videoMuted, userDisplayName: $userDisplayName, userEmail: $userEmail, userAvatarURL: $userAvatarURL, featureFlags: ${getFeatureFlags()} }';
  }

/* Not used yet, needs more research
  Bundle colorScheme;
  String userAvatarURL;
*/
}
