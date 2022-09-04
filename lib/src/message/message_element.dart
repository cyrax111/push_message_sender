import 'message.dart';
import 'message_exception.dart';

abstract class MessageElement {
  /// throws [MessageException]
  Map<String, Object> build();
}

class ElementWrapper implements MessageElement {
  ElementWrapper({required this.body});
  final Map<String, Object> body;
  @override
  Map<String, Object> build() => {'message': body};
}

class TargetElement implements MessageElement {
  const TargetElement({
    this.token,
    this.topic,
    this.condition,
  });
  final String? token;
  final String? topic;
  final String? condition;

  @override
  Map<String, String> build() {
    final isTokenSet = token != null;
    final isTopicSet = topic != null;
    final isConditionSet = condition != null;

    var amountOfSetParameters = 0;

    Map<String, String> result = {};

    if (isTokenSet) {
      result = <String, String>{
        'token': token!,
      };
      amountOfSetParameters++;
    }

    if (isTopicSet) {
      result = <String, String>{
        'topic': topic!,
      };
      amountOfSetParameters++;
    }

    if (isConditionSet) {
      result = <String, String>{
        'condition': condition!,
      };
      amountOfSetParameters++;
    }

    final isSetNotOnlyOneParameter = amountOfSetParameters != 1;
    if (isSetNotOnlyOneParameter) {
      throw MessageException(
          'There is not only one parameter set or no parameters set',
          details: 'token: $token, topic: $topic, condition: $condition');
    }

    return result;
  }
}

class NotificationElement implements MessageElement {
  NotificationElement({
    this.title = '',
    this.body = '',
    this.image,
  });

  final String title;
  final String body;
  final String? image;

  @override
  Map<String, Object> build() {
    final built = {
      'notification': {
        'title': title,
        'body': body,
        if (image != null) 'image': image!,
      },
    };
    return built;
  }
}

class DataElement with JsonEncoder implements MessageElement {
  DataElement({required this.data});

  final Map<String, Object> data;

  @override
  Map<String, Object> build() {
    final built = {
      'data': jsonEncode(data),
    };
    return built;
  }
}
