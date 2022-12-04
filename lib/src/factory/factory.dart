import 'package:http/http.dart' as http;
import 'package:jwt_manager/jwt_manager.dart';

import 'package:push_message_sender/push_message_sender.dart';
import 'package:push_message_sender/src/access_token_manager/access_token_manager.dart';

/// Interface for constructing [PushMessageSender]
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
