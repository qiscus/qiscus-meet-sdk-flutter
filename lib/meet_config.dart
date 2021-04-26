import 'package:qiscus_meet/meet_jwt_config.dart';

class MeetConfig {
  var enablePassword = false;
  var enableChat = false;
  var overflowMenu = false;
  var videoThumbnailsOn = true;
  var enableRoomName = true;
  var jwtPayload = "";
  var jwtConfig = MeetJwtConfig();

  void setJwtConfig(MeetJwtConfig jwtConfig) {
    this.jwtConfig = jwtConfig;
  }

  MeetJwtConfig getJwtConfig() {
    return jwtConfig;
  }
}
