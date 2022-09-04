import 'package:push_message_sender/src/exception.dart';

class FactoryException extends PushMessageSenderException {
  FactoryException(super.message, {super.details, super.stackTrace});
}
