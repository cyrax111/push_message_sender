import 'factory.dart';

/// A convenient class that build [PushMessageSender] from a pem string
class SenderFactoryFromPemString
    with SenderFactoryMixin
    implements SenderFactory {
  SenderFactoryFromPemString({
    required this.clientEmail,
    required this.privateKeyPem,
    required this.projectName,
    required this.tokenUriString,
  });
  @override
  final String clientEmail;
  @override
  final String privateKeyPem;
  @override
  final String projectName;
  @override
  final String tokenUriString;
}
