import 'client_token.dart';
import 'fcm_message.dart';
import 'message_element.dart';

class MulticastMessageBuilder {
  MulticastMessageBuilder({
    required this.clientTokens,
    required this.fcmMessageBody,
  });
  final List<ClientToken> clientTokens;
  final FcmMessageBody fcmMessageBody;

  /// throws [MessageException]
  List<FcmMessage> build() {
    final builtMessages = <FcmMessage>[];
    final targetElements =
        clientTokens.map((token) => TargetElement(token: token));
    for (final targetElement in targetElements) {
      builtMessages.add(FcmMessage(
        targetElement: targetElement,
        fcmMessageBody: fcmMessageBody,
      ));
    }

    return builtMessages;
  }
}
