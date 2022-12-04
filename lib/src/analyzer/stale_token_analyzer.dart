import 'package:push_message_sender/push_message_sender.dart';
import 'package:push_message_sender/src/analyzer/analyzer_exception.dart';
import 'package:push_message_sender/src/message_response/message_response.dart';

/// Checks [responses] and exposes [staleTokens] as the result
class StaleTokenAnalyzer {
  StaleTokenAnalyzer({
    required this.messages,
    required this.responses,
  }) {
    _getStaleTokens();
  }
  final List<FcmMessage> messages;
  final List<MessageResponse> responses;

  late final Set<ClientToken> staleTokens;

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
    staleTokens = {};
    final length = messages.length;
    for (var i = 0; i < length; i++) {
      final response = responses[i];
      if (response is MessageExceptionResponse) {
        if (response.messageException.status ==
            MessageExceptionStatus.unregistered) {
          final target = messages[i].targetElement;
          if (target.isToken) {
            staleTokens.add(target.token!);
          }
        }
      }
    }
  }
}
