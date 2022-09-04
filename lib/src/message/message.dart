import 'dart:convert' as json;

import 'message_exception.dart';

abstract class Message {
  const factory Message.fromString(String encodedMessage) = _MessageFromString;
  const factory Message.fromMap(Map<String, Object> encodedMessage) =
      _MessageFromMap;

  /// throws [MessageException]
  String get encoded;

  @override
  String toString() {
    return encoded;
  }
}

class _MessageFromString implements Message {
  const _MessageFromString(this.encoded);
  @override
  final String encoded;
}

class _MessageFromMap with JsonEncoder implements Message {
  const _MessageFromMap(this.message);

  final Map<String, Object> message;

  @override
  String get encoded => jsonEncode(message);
}

mixin JsonEncoder {
  String jsonEncode(Map<String, Object> input) {
    try {
      return jsonEncode(input);
    } on json.JsonUnsupportedObjectError catch (e, stackTrace) {
      throw MessageException('Converting to string (json encode) message error',
          details: e, stackTrace: stackTrace);
    }
  }
}
