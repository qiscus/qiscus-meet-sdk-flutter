/// status : "true"
/// token : "eyJraWQiOiJxaXNjdXNtZWV0IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsibmFtZSI6Ikd1c3R1IiwiYXZhdGFyIjpudWxsLCJlbWFpbCI6bnVsbH0sImdyb3VwIjpudWxsfSwibW9kZXJhdG9yIjpudWxsLCJhdWQiOm51bGwsImlzcyI6bnVsbCwic3ViIjpudWxsLCJyb29tIjoiYWJjIiwiZXhwIjoxNjEzNjI4MzY2fQ.lbrWfx8JuIJu7snYVGEHqyArMg6a4VOfq5WjPH9KaGtbuWgNurSLx7XVsWJRjpiM52i5I_sOskq_PNMV3riKupAaJXob1tzjaduXKDSpbn8Pz9Lgf2Bopa1bN8QlVHzXY5jwmgEyIwZrJ_JhokRd7Me-4OYx3WZsTJnLTwqGlLQ"
/// shortenUrl : null
/// url : "https://call.qiscus.com/abc?jwt=eyJraWQiOiJxaXNjdXNtZWV0IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsibmFtZSI6Ikd1c3R1IiwiYXZhdGFyIjpudWxsLCJlbWFpbCI6bnVsbH0sImdyb3VwIjpudWxsfSwibW9kZXJhdG9yIjpudWxsLCJhdWQiOm51bGwsImlzcyI6bnVsbCwic3ViIjpudWxsLCJyb29tIjoiYWJjIiwiZXhwIjoxNjEzNjI4MzY2fQ.lbrWfx8JuIJu7snYVGEHqyArMg6a4VOfq5WjPH9KaGtbuWgNurSLx7XVsWJRjpiM52i5I_sOskq_PNMV3riKupAaJXob1tzjaduXKDSpbn8Pz9Lgf2Bopa1bN8QlVHzXY5jwmgEyIwZrJ_JhokRd7Me-4OYx3WZsTJnLTwqGlLQ"

class Qiscus_response {
  String _status;
  String _token;
  dynamic _shortenUrl;
  String _url;

  String get status => _status;
  String get token => _token;
  dynamic get shortenUrl => _shortenUrl;
  String get url => _url;

  Qiscus_response({
      String status, 
      String token, 
      dynamic shortenUrl, 
      String url}){
    _status = status;
    _token = token;
    _shortenUrl = shortenUrl;
    _url = url;
}

  Qiscus_response.fromJson(dynamic json) {
    _status = json["status"];
    _token = json["token"];
    _shortenUrl = json["shortenUrl"];
    _url = json["url"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["status"] = _status;
    map["token"] = _token;
    map["shortenUrl"] = _shortenUrl;
    map["url"] = _url;
    return map;
  }

}