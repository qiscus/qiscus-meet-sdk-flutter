import 'meet_config.dart';
import 'meet_info.dart';

class QiscusMeet {
  static MeetConfig qiscusConfig;
  static var appId = "";
  static var url = "https://call.qiscus.com";

  static void setup(String appId, String url) {
    QiscusMeet.url = url;
    QiscusMeet.appId = appId;
    QiscusMeet.qiscusConfig = MeetConfig();
    var config = QiscusMeetOptions();
    config.serverURL = url.toString();
  }

  static String getAPPId() {
    return QiscusMeet.appId;
  }

  static MeetInfo call(String roomId, String displayName, String avatar,
      String callKit, bool audioMuted, bool videoMuted) {
    return MeetInfo(url.toString(), QiscusMeetTypeCaller.CALLER, qiscusConfig,
        roomId, displayName, avatar, callKit, audioMuted,videoMuted);
  }

  static MeetConfig config() {
    return qiscusConfig;
  }

  static void endCall() {
    return MeetInfo.endCall();
  }
}

enum QiscusMeetType { VIDEO, VOICE, CONFERENCE }
enum QiscusMeetTypeCaller { CALLER, CALLEE }
