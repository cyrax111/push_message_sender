import 'message.dart';
import 'message_element.dart';

class MulticastMessageBuilder {
  MulticastMessageBuilder({
    required this.clientTokens,
    required this.messageElements,
  });
  final List<ClientToken> clientTokens;
  final List<MessageElement> messageElements;

  /// throws [MessageException]
  List<Message> build() {
    final builtMessages = <Message>[];
    final messageWithoutTarget = _constructMessageWithoutTarget();
    for (final token in clientTokens) {
      final target = _constructTarget(token);
      final messageWithTarget =
          _addTargetToMessage(target: target, message: messageWithoutTarget);
      final wrappedMessage = ElementWrapper(body: messageWithTarget).build();
      final builtMessageFromMap = Message.fromMap(wrappedMessage);
      builtMessages.add(builtMessageFromMap);
    }

    return builtMessages;
  }

  Map<String, Object> _constructMessageWithoutTarget() {
    Map<String, Object> constructedMessage = {};
    for (final element in messageElements) {
      constructedMessage.addAll(element.build());
    }
    return constructedMessage;
  }

  Map<String, Object> _constructTarget(ClientToken token) {
    return TargetElement(token: token).build();
  }

  Map<String, Object> _addTargetToMessage(
      {required Map<String, Object> target,
      required Map<String, Object> message}) {
    Map<String, Object> constructedMessage = <String, Object>{};
    constructedMessage.addAll(target);
    constructedMessage.addAll(message);
    return constructedMessage;
  }
}

typedef ClientToken = String;
