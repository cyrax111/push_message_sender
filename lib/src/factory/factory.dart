import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jwt_manager/jwt_manager.dart';

import 'package:push_message_sender/push_message_sender.dart';
import 'package:push_message_sender/src/access_token_manager/access_token_manager.dart';

import 'factory_exception.dart';

abstract class SenderFactory {
  PushMessageSender build();
  void dispose();
}

mixin SenderFactoryMixin implements SenderFactory {
  String get clientEmail;
  String get privateKeyPem;
  String get projectName;
  String get tokenUriString;

  late final http.Client httpClient;
  late final AccessTokenManager accessTokenManager;

  @override
  PushMessageSender build() {
    final tokenDto = FcmTokenDto(
      iss: clientEmail,
    );

    final parser = RsaKeyParser();
    final rsaPrivateKey = parser.extractPrivateKey(privateKeyPem);

    final rsaSignifier = RsaSignifier(privateKey: rsaPrivateKey);

    final jwtBuilder = JwtBuilder(signifier: rsaSignifier);

    httpClient = http.Client();

    final tokenUri = Uri.parse(tokenUriString);
    accessTokenManager = FcmAccessTokenManager(
        tokenUri: tokenUri,
        token: tokenDto,
        jwtBuilder: jwtBuilder,
        httpClient: httpClient);

    final fcmSettings = FcmSettings(projectName: projectName);

    final PushMessageSender sender = PushMessageSenderHttpV1(
        client: httpClient,
        accessTokenManager: accessTokenManager,
        settings: fcmSettings,
        messageResponseParser: FcmMessageResponseParser(),
        batchResponseParser: FcmBatchResponseParser(
            innerMessageResponseParser: FcmMessageResponseParser()));

    return sender;
  }

  @override
  void dispose() {
    accessTokenManager.dispose();
    httpClient.close();
  }
}

class SenderFactoryFromPemString
    with SenderFactoryMixin
    implements SenderFactory {
  SenderFactoryFromPemString({
    required this.clientEmail,
    required this.privateKeyPem,
    required this.projectName,
    required this.tokenUriString,
  });
  @override
  final String clientEmail;
  @override
  final String privateKeyPem;
  @override
  final String projectName;
  @override
  final String tokenUriString;
}

class SenderFactoryFromFirebaseFile
    with SenderFactoryMixin
    implements SenderFactory {
  SenderFactoryFromFirebaseFile({required this.jsonFile}) {
    if (!jsonFile.existsSync()) {
      throw FactoryException('File `${jsonFile.path}` is not found',
          details: '''
Please download the Firebase Admin SDK private key and use that file. 
For detail information how to get the private key file see `README.md` .
Or one can use [SenderFactoryFromPemString] with assigning a private key directly through a string.
''');
    }
    try {
      final json = jsonFile.readAsStringSync();
      final map = jsonDecode(json);

      clientEmail = map['client_email'];
      privateKeyPem = map['private_key'];
      projectName = map['project_id'];
      tokenUriString = map['token_uri'];
    } catch (e, stackTrace) {
      throw FactoryException(
          'Getting info from the file (${jsonFile.path}) error',
          details: e,
          stackTrace: stackTrace);
    }
  }

  final File jsonFile;
  @override
  late final String clientEmail;
  @override
  late final String privateKeyPem;
  @override
  late final String projectName;
  @override
  late final String tokenUriString;
}
