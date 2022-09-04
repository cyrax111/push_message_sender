abstract class MessageResponse {
  bool get isSuccessful;
}

class MessageSuccessResponse implements MessageResponse {
  MessageSuccessResponse({required this.messageId});

  @override
  final bool isSuccessful = true;

  final String messageId;

  @override
  String toString() {
    return 'MessageSuccessResponse(messageId: $messageId)';
  }
}

class MessageExceptionResponse implements MessageResponse {
  MessageExceptionResponse({required this.messageException});

  @override
  final bool isSuccessful = false;

  final MessageException messageException;

  @override
  String toString() {
    return 'MessageExceptionResponse(messageException: $messageException)';
  }
}

class MessageException {
  MessageException({
    required this.code,
    required this.message,
    required this.status,
    required this.details,
  });
  final int code;
  final String message;
  final MessageExceptionStatus status;
  final Object? details;

  @override
  String toString() {
    return 'MessageException(code: $code, status: $status, message: $message, details: $details)';
  }
}

/// https://firebase.google.com/docs/reference/fcm/rest/v1/ErrorCode
enum MessageExceptionStatus {
  unspecifiedError(text: 'UNSPECIFIED_ERROR'),
  invalidArgument(text: 'INVALID_ARGUMENT'),
  unregistered(text: 'UNREGISTERED'),
  senderIdMismatch(text: 'SENDER_ID_MISMATCH'),
  quoteExceeded(text: 'QUOTA_EXCEEDED'),
  unavailable(text: 'UNAVAILABLE'),
  internal(text: 'INTERNAL'),
  thirdPartyAuthError(text: 'THIRD_PARTY_AUTH_ERROR'),
  innerError(text: 'INNER_ERROR');

  const MessageExceptionStatus({required this.text});

  final String text;
}

class BatchResponse {
  BatchResponse({
    required this.successCount,
    required this.failureCount,
    required this.responses,
  });
  final int successCount;
  final int failureCount;
  final List<MessageResponse> responses;

  BatchResponse operator +(BatchResponse other) {
    return BatchResponse(
      successCount: successCount + other.successCount,
      failureCount: failureCount + other.failureCount,
      responses: [...responses, ...other.responses],
    );
  }

  @override
  String toString() {
    return 'BatchResponse(success: $successCount, failure: $failureCount, responses: $responses)';
  }
}
