class FcmSettings {
  FcmSettings({
    required this.projectName,
  });

  final String projectName;

  Uri get singleUrl => Uri.https(
      'fcm.googleapis.com', '/v1/projects/$projectName/messages:send');
  Map<String, String> singleHeaders({required String accessToken}) =>
      <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

  static const String subrequestBoundary = 'subrequest_boundary';
  Uri get batchUrl => Uri.https('fcm.googleapis.com', '/batch');
  Map<String, String> batchHeaders() => <String, String>{
        'Content-Type': 'multipart/mixed; boundary="$subrequestBoundary"',
      };

  final String batchBoardStart = '--$subrequestBoundary';
  final String batchBoardEnd = '--$subrequestBoundary--';
  String batchSubrequestHeaders({required String accessToken}) => '''
Content-Type: application/http
Content-Transfer-Encoding: binary
Authorization: Bearer $accessToken

POST /v1/projects/$projectName/messages:send
Content-Type: application/json
accept: application/json
''';
}
