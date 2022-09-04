import 'package:push_message_sender/push_message_sender.dart';

class AccessTokenManagerException extends PushMessageSenderException {
  AccessTokenManagerException(super.message, {super.details, super.stackTrace});
}

class WrongFormatAccessTokenResponseException
    extends PushMessageSenderException {
  WrongFormatAccessTokenResponseException(super.message,
      {super.details, super.stackTrace});
}
