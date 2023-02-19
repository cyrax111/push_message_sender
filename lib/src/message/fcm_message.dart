import 'message.dart';
import 'message_element.dart';

class FcmMessage extends Message with JsonEncoder {
  FcmMessage({
    required this.targetElement,
    required this.fcmMessageBody,
  }) {
    final Map<String, dynamic> empty = {};

    final withTarget = _addTarget(empty);
    final withBody = _addBody(withTarget);

    encoded = _wrapAndEncode(withBody);
  }

  final TargetElement targetElement;
  final FcmMessageBody fcmMessageBody;

  @override
  late final String encoded;

  String _wrapAndEncode(Map<String, dynamic> built) {
    final wrappedMessage = ElementWrapper(body: built).built;
    return encodeToJson(wrappedMessage);
  }

  Map<String, dynamic> _addTarget(Map<String, dynamic> built) {
    return built..addAll(targetElement.built);
  }

  Map<String, dynamic> _addBody(Map<String, dynamic> built) {
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
  final Map<String, dynamic> built = {};

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
