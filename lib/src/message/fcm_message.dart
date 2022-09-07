import 'message.dart';
import 'message_element.dart';

class FcmMessage with JsonEncoder implements Message {
  FcmMessage({
    required this.targetElement,
    required this.fcmMessageBody,
  }) {
    final Map<String, Object> empty = {};

    final withTarget = _addTarget(empty);
    final withBody = _addBody(withTarget);

    encoded = _wrapAndEncode(withBody);
  }

  final TargetElement targetElement;
  final FcmMessageBody fcmMessageBody;

  @override
  late final String encoded;

  String _wrapAndEncode(Map<String, Object> built) {
    final wrappedMessage = ElementWrapper(body: built).built;
    return jsonEncode(wrappedMessage);
  }

  Map<String, Object> _addTarget(Map<String, Object> built) {
    return built..addAll(targetElement.built);
  }

  Map<String, Object> _addBody(Map<String, Object> built) {
    return built..addAll(fcmMessageBody.built);
  }
}

class FcmMessageBody implements MessageElement {
  FcmMessageBody({
    this.notificationElement,
    this.dataElement,
  }) {
    _addDataIfExists();
    _addNotificationIfExists();
  }

  final NotificationElement? notificationElement;
  final DataElement? dataElement;

  @override
  final Map<String, Object> built = {};

  void _addNotificationIfExists() {
    final notification = notificationElement;
    if (notification != null) {
      built.addAll(notification.built);
    }
  }

  void _addDataIfExists() {
    final data = dataElement;
    if (data != null) {
      built.addAll(data.built);
    }
  }
}
