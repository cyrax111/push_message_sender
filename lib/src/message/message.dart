import 'dart:convert' as json;

import 'message_exception.dart';

abstract class Message {
  const Message();
  const factory Message.fromString(String encodedMessage) = _MessageFromString;
  const factory Message.fromMap(Map<String, dynamic> encodedMessage) =
      _MessageFromMap;

  /// throws [MessageException]
  String get encoded;

  @override
  String toString() {
    return encoded;
  }
}

class _MessageFromString extends Message {
  const _MessageFromString(this.encoded);
  @override
  final String encoded;
}

class _MessageFromMap extends Message with JsonEncoder {
  const _MessageFromMap(this.message);

  final Map<String, dynamic> message;

  @override
  String get encoded => encodeToJson(message);
}

mixin JsonEncoder {
  String encodeToJson(
    Map<String, dynamic> input, {
    Object? Function(Object?)? toEncodable,
  }) {
    try {
      return json.jsonEncode(input, toEncodable: toEncodable);
    } on json.JsonUnsupportedObjectError catch (e, stackTrace) {
      throw MessageException('Converting to string (json encode) message error',
          details: e, stackTrace: stackTrace);
    }
  }
}
