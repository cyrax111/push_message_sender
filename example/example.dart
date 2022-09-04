import 'dart:io';

import 'package:push_message_sender/push_message_sender.dart';

void main() async {
  final factory = SenderFactoryFromFirebaseFile(
      jsonFile: File('private_key/firebase-adminsdk-wfvew-d111a89deb.json'));
  final PushMessageSender sender = factory.build();

  // send a single message
  final singleMessage = FcmMessage(
      targetElement: TargetElement(topic: 'goal'),
      notificationElement: NotificationElement(
        title: 'title',
        body: 'body',
      ));
  final response = await sender.send(singleMessage);

  // send multiple messages
  // final multicastMessage = MulticastMessageBuilder(
  //   clientTokens: [
  //     'clientTokens1',
  //     'clientTokens2',
  //     'clientTokens3',
  //   ],
  //   messageElements: [
  //     MessageNotification(title: 'title', body: 'body'),
  //   ],
  // ).build();
  // final response = await sender.sendMulticast(multicastMessage);

  print(response);

  factory.dispose();
}
