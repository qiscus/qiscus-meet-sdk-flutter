import 'dart:collection';

import 'package:qiscus_meet/qiscus_meet.dart';

class MeetJwtConfig {
  var appId = QiscusMeet.getAPPId();
  var email = "";
  var iss = "meetcall";
  var sub = Uri.parse(QiscusMeet.url).host;
  var moderator = false;
  Map <String,Object> jwtPayload = new HashMap();

  void setEmail(String email) {
    this.email = email;
  }
  void build() {
    jwtPayload["appId"] = appId;
    jwtPayload["email"] = email;
    jwtPayload["moderator"]= moderator;
    jwtPayload["iss"] = iss;
    jwtPayload["sub"] = sub;
  }
  Map<String,Object> getJwtPayload() {
    return jwtPayload;
  }


}
