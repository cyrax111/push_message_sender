import 'package:push_message_sender/push_message_sender.dart';

class FcmAccessTokenManagerException extends PushMessageSenderException {
  FcmAccessTokenManagerException(super.message,
      {super.details, super.stackTrace});
}

class WrongFormatAccessTokenResponseException
    extends PushMessageSenderException {
  WrongFormatAccessTokenResponseException(super.message,
      {super.details, super.stackTrace});
}
