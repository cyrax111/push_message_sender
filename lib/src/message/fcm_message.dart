import 'message.dart';
import 'message_element.dart';

class FcmMessage with JsonEncoder implements Message {
  FcmMessage({
    required this.targetElement,
    this.notificationElement,
    this.dataElement,
  });
  final TargetElement targetElement;
  final NotificationElement? notificationElement;
  final DataElement? dataElement;

  final Map<String, Object> result = {};

  // TODO(any): add others elements
  @override
  String get encoded {
    _addTarget();
    _addNotificationIfExists();
    _addDataIfExists();
    return _wrapAndEncode();
  }

  String _wrapAndEncode() {
    final wrappedMessage = ElementWrapper(body: result).build();
    return jsonEncode(wrappedMessage);
  }

  void _addTarget() {
    result.addAll(targetElement.build());
  }

  void _addNotificationIfExists() {
    final notification = notificationElement;
    if (notification != null) {
      result.addAll(notification.build());
    }
  }

  void _addDataIfExists() {
    final data = dataElement;
    if (data != null) {
      result.addAll(data.build());
    }
  }
}
