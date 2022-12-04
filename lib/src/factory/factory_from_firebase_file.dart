import 'dart:convert';
import 'dart:io';

import 'factory.dart';
import 'factory_exception.dart';

/// A convenient class that build [PushMessageSender] from a firebase admin sdk file
class SenderFactoryFromFirebaseFile
    with SenderFactoryMixin
    implements SenderFactory {
  SenderFactoryFromFirebaseFile({required this.jsonFile}) {
    if (!jsonFile.existsSync()) {
      throw FactoryException('File `${jsonFile.path}` is not found',
          details: '''
Please download the Firebase Admin SDK private key and use that file. 
For detail information how to get the private key file see `README.md` .
Or one can use [SenderFactoryFromPemString] with assigning a private key directly through a string.
''');
    }
    try {
      final json = jsonFile.readAsStringSync();
      final map = jsonDecode(json);

      clientEmail = map['client_email'];
      privateKeyPem = map['private_key'];
      projectName = map['project_id'];
      tokenUriString = map['token_uri'];
    } catch (e, stackTrace) {
      throw FactoryException(
          'Getting info from the file (${jsonFile.path}) error',
          details: e,
          stackTrace: stackTrace);
    }
  }

  final File jsonFile;
  @override
  late final String clientEmail;
  @override
  late final String privateKeyPem;
  @override
  late final String projectName;
  @override
  late final String tokenUriString;
}
