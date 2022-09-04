import 'package:push_message_sender/src/message/message.dart';
import 'package:push_message_sender/src/message_response/message_response.dart';

abstract class PushMessageSender {
  Future<MessageResponse> send(Message message);
  Future<BatchResponse> sendMulticast(Iterable<Message> messages);
}
