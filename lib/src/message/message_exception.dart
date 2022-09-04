import 'package:push_message_sender/src/exception.dart';

class MessageException extends PushMessageSenderException {
  MessageException(super.message, {super.details, super.stackTrace});
}
