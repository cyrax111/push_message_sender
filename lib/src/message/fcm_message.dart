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

  late Map<String, Object> _result;

  // TODO(any): add others elements
  @override
  String get encoded {
    _result = {};

    _addTarget();
    _addNotificationIfExists();
    _addDataIfExists();

    return _wrapAndEncode();
  }

  String _wrapAndEncode() {
    final wrappedMessage = ElementWrapper(body: _result).build();
    return jsonEncode(wrappedMessage);
  }

  void _addTarget() {
    _result.addAll(targetElement.build());
  }

  void _addNotificationIfExists() {
    final notification = notificationElement;
    if (notification != null) {
      _result.addAll(notification.build());
    }
  }

  void _addDataIfExists() {
    final data = dataElement;
    if (data != null) {
      _result.addAll(data.build());
    }
  }
}
