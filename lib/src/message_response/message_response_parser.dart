import 'dart:convert';

import 'package:push_message_sender/src/message_response/message_response.dart';

import 'message_response_exception.dart';

abstract class MessageResponseParser {
  MessageResponse extract(String inputString);
}

class FcmMessageResponseParser implements MessageResponseParser {
  @override
  MessageResponse extract(String inputString) {
    final extracted = _extractBody(inputString);
    final decoded = _decodeBody(extracted);
    final messageResponse = _buildMessageResponse(decoded);
    return messageResponse;
  }

  String _extractBody(String inputString) {
    final firstIndex = inputString.indexOf('{');
    final lastIndex = inputString.lastIndexOf('}');

    if (firstIndex == -1 || lastIndex == -1) {
      throw MessageResponseParserException(
        'Body is not found',
        details:
            'firstIndex of "{" is $firstIndex, lastIndex of "}" is $lastIndex',
      );
    }
    final body = inputString.substring(firstIndex, lastIndex + 1);
    return body;
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded as Map<String, dynamic>;
    } catch (e, stackTrace) {
      throw MessageResponseParserException('Wrong json format',
          details: e, stackTrace: stackTrace);
    }
  }

  MessageResponse _buildMessageResponse(Map<String, dynamic> decoded) {
    try {
      final isException = decoded.keys.contains('error');
      MessageResponse messageResponse;
      if (isException) {
        final error = decoded['error'] as Map<String, dynamic>;
        final status = MessageExceptionStatus.values.firstWhere(
            (element) => element.text == error['status'],
            orElse: () => MessageExceptionStatus.unspecifiedError);

        messageResponse = MessageExceptionResponse(
          messageException: MessageException(
            code: error['code'] as int,
            message: error['message'] as String,
            details: error['details'] as List?,
            status: status,
          ),
        );
      } else {
        final name = decoded['name'] as String;
        messageResponse = MessageSuccessResponse(messageId: name);
      }
      return messageResponse;
    } catch (e, stackTrace) {
      throw MessageResponseParserException(
          'Building MessageResponse object error',
          details: e,
          stackTrace: stackTrace);
    }
  }
}

abstract class BatchResponseParser {
  BatchResponse extract(String inputString);
}

class FcmBatchResponseParser implements BatchResponseParser {
  FcmBatchResponseParser({
    required MessageResponseParser innerMessageResponseParser,
  }) : _innerMessageResponseParser = innerMessageResponseParser;

  final MessageResponseParser _innerMessageResponseParser;

  @override
  BatchResponse extract(String inputString) {
    final extractedMessages = _extractMessages(inputString);
    final batchResponse = _buildMessages(extractedMessages);
    return batchResponse;
  }

  List<String> _extractMessages(String inputString) {
    const batchSign = '--batch';
    final extractedMessages = inputString.split(batchSign);
    final batchSignCount = extractedMessages.length;
    if (batchSignCount < 2) {
      throw MessageResponseParserException('Batch body incorrect format',
          details: 'count of a batch sign is $batchSignCount (less then two)');
    }
    extractedMessages.removeLast();
    extractedMessages.removeAt(0);
    if (extractedMessages.isEmpty) {
      throw MessageResponseParserException('No messages',
          details: 'count of extracted messages is zero');
    }
    return extractedMessages;
  }

  BatchResponse _buildMessages(List<String> messages) {
    var successCount = 0;
    var failureCount = 0;
    final extractedMessages = <MessageResponse>[];
    for (final message in messages) {
      final extractedMessage = _extract(message);
      extractedMessages.add(extractedMessage);
      if (extractedMessage.isSuccessful) {
        successCount++;
      } else {
        failureCount++;
      }
    }
    return BatchResponse(
      successCount: successCount,
      failureCount: failureCount,
      responses: extractedMessages,
    );
  }

  MessageResponse _extract(String inputString) {
    try {
      return _innerMessageResponseParser.extract(inputString);
    } catch (e) {
      return MessageExceptionResponse(
        messageException: MessageException(
            code: 0,
            status: MessageExceptionStatus.innerError,
            message: 'inner message parse exception',
            details: e),
      );
    }
  }
}
