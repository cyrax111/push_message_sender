import 'package:http/http.dart';
import 'package:push_message_sender/src/access_token_manager/access_token_manager.dart';
import 'package:push_message_sender/src/extension/iterable_ext.dart';
import 'package:push_message_sender/src/message/message.dart';
import 'package:push_message_sender/src/message_response/message_response.dart';
import 'package:push_message_sender/src/message_response/message_response_parser.dart';

import 'fcm_settings.dart';
import 'push_message_sender.dart';

class PushMessageSenderHttpV1 implements PushMessageSender {
  PushMessageSenderHttpV1({
    required Client client,
    required AccessTokenManager accessTokenManager,
    required FcmSettings settings,
    required MessageResponseParser messageResponseParser,
    required BatchResponseParser batchResponseParser,
  })  : _client = client,
        _accessTokenManager = accessTokenManager,
        _settings = settings,
        _messageResponseParser = messageResponseParser,
        _batchResponseParser = batchResponseParser;

  static const int maxMessagesInOneBatchRequest = 500;

  final Client _client;
  final AccessTokenManager _accessTokenManager;
  final FcmSettings _settings;
  final MessageResponseParser _messageResponseParser;
  final BatchResponseParser _batchResponseParser;

  // throws IOException and PushMessengerException
  @override
  Future<MessageResponse> send(Message message) async {
    final accessToken = await _accessTokenManager.accessToken;

    final response = await _client.post(
      _settings.singleUrl,
      headers: _settings.singleHeaders(accessToken: accessToken),
      body: message.encoded,
    );

    return _messageResponseParser.extract(response.body);
  }

  @override
  Future<BatchResponse> sendMulticast(Iterable<Message> messages) async {
    if (messages.isEmpty) {
      return BatchResponse.empty();
    }
    final batchResponses = await messages.separate<BatchResponse>(
        partLength: maxMessagesInOneBatchRequest, executer: _sendMulticast);
    final unionBatchResponse =
        batchResponses.reduce((value, element) => value + element);
    return unionBatchResponse;
  }

  Future<BatchResponse> _sendMulticast(Iterable<Message> messages) async {
    final batchBody = await _buildBatchBody(messages);
    final response = await _client.post(
      _settings.batchUrl,
      headers: _settings.batchHeaders(),
      body: batchBody,
    );

    return _batchResponseParser.extract(response.body);
  }

  Future<String> _buildBatchBody(Iterable<Message> messages) async {
    final body = StringBuffer();
    final accessToken = await _accessTokenManager.accessToken;
    for (final message in messages) {
      body.writeln(_settings.batchBoardStart);
      body.writeln(_settings.batchSubrequestHeaders(accessToken: accessToken));
      body.writeln();
      body.writeln(message.encoded);
      body.writeln();
    }
    body.writeln(_settings.batchBoardEnd);
    return body.toString();
  }
}
