import 'package:push_message_sender/src/message/client_token.dart';
import 'package:push_message_sender/src/message/fcm_message.dart';
import 'package:push_message_sender/src/message_response/message_response.dart';

import 'analyzer_exception.dart';

/// Checks [responses] by [analyzerCheckers] and exposes [satisfiedTokens] as the result
class TokenAnalyzer {
  TokenAnalyzer({
    required this.messages,
    required this.responses,
    required List<AnalyzerChecker> analyzerCheckers,
  }) : _analyzerCheckers = analyzerCheckers {
    _getStaleTokens();
  }
  final List<FcmMessage> messages;
  final List<MessageResponse> responses;
  final List<AnalyzerChecker> _analyzerCheckers;

  late final Set<ClientToken> satisfiedTokens;

  void _getStaleTokens() {
    _checkLengthsMatch();
    _fillStaleTokens();
  }

  void _checkLengthsMatch() {
    if (messages.length != responses.length) {
      throw AnaLyzerException(
          'Messages length (${messages.length}) does not match responses length (${responses.length})');
    }
  }

  void _fillStaleTokens() {
    satisfiedTokens = {};
    final length = messages.length;
    for (var i = 0; i < length; i++) {
      final satisfiedToken = _analyzerCheckers
          .map((checker) => checker.check(
                message: messages[i],
                response: responses[i],
              ))
          .firstWhere(
            (token) => token != null,
            orElse: () => null,
          );
      if (satisfiedToken != null) {
        satisfiedTokens.add(satisfiedToken);
      }
    }
  }
}

abstract class AnalyzerChecker {
  ClientToken? check({
    required FcmMessage message,
    required MessageResponse response,
  });
}
