import 'package:push_message_sender/src/message/client_token.dart';
import 'package:push_message_sender/src/message/fcm_message.dart';
import 'package:push_message_sender/src/message_response/message_response.dart';

import 'token_analyzer.dart';

class CheckerInvalidToken implements AnalyzerChecker {
  const CheckerInvalidToken();
  @override
  ClientToken? check({
    required FcmMessage message,
    required MessageResponse response,
  }) {
    if (response is MessageExceptionResponse) {
      if (response.messageException.status ==
          MessageExceptionStatus.invalidArgument) {
        final target = message.targetElement;
        if (target.isToken) {
          return target.token;
        }
      }
    }
    return null;
  }
}
