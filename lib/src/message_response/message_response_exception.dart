import 'package:push_message_sender/push_message_sender.dart';

class MessageResponseParserException extends PushMessageSenderException {
  MessageResponseParserException(super.message,
      {super.details, super.stackTrace});
}
