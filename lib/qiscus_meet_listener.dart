/// Class holding the callback functions for conference events
class QiscusMeetListener {
  final Function({Map<dynamic, dynamic> message}) onConferenceWillJoin;
  final Function({Map<dynamic, dynamic> message}) onConferenceJoined;
  final Function({Map<dynamic, dynamic> message}) onConferenceTerminated;
  final Function({Map<dynamic, dynamic> message}) onPictureInPictureWillEnter;
  final Function({Map<dynamic, dynamic> message}) onPictureInPictureTerminated;
  final Function({Map<dynamic, dynamic> message}) onParticipantJoined;
  final Function({Map<dynamic, dynamic> message}) onParticipantLeft;
  final Function({Map<dynamic, dynamic> message}) onRecordingStatus;
  final Function(dynamic error) onError;

  QiscusMeetListener(
      {this.onConferenceWillJoin,
      this.onConferenceJoined,
      this.onConferenceTerminated,
      this.onPictureInPictureWillEnter,
      this.onPictureInPictureTerminated,
      this.onParticipantJoined,
      this.onParticipantLeft,
      this.onRecordingStatus,
      this.onError});
}
