import 'dart:async';
import 'dart:convert';

import 'package:emptyable_timer/emptyable_timer.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_manager/jwt_manager.dart';
import 'package:meta/meta.dart';

import 'access_token_manager_exception.dart';

abstract class AccessTokenManager {
  AccessTokenManager() {
    _initialFetchingAccessTokenAndSetTimer();
  }

  /// [accessToken] always consist a fresh access token
  late Future<String> accessToken;

  void dispose() => _timer.cancel();

  @protected
  Future<AccessTokenResponse> fetchAccessToken();

  EmptyableTimer _timer = EmptyableTimer.empty();

  Future<void> _initialFetchingAccessTokenAndSetTimer() async {
    final fetchAccessTokenCompleter = Completer<String>();
    accessToken = fetchAccessTokenCompleter.future;

    try {
      final response = await fetchAccessToken();
      fetchAccessTokenCompleter.complete(response.accessToken);
      _updateTimer(response.expiresIn);
    } catch (error, stackTrace) {
      fetchAccessTokenCompleter.completeError(error, stackTrace);
    }
  }

  Future<void> _updateAccessTokenAndTimer() async {
    try {
      final response = await fetchAccessToken();
      accessToken = Future.value(response.accessToken);
      _updateTimer(response.expiresIn);
    } catch (error, stackTrace) {
      accessToken = Future.error(error, stackTrace);
    }
  }

  void _updateTimer(Duration expiresIn) {
    if (_timer.isCanceled) {
      return;
    }
    _timer = EmptyableTimer(
      _tokenUpdateDuration(expiresIn: expiresIn),
      _updateAccessTokenAndTimer,
    );
  }

  Duration _tokenUpdateDuration({required Duration expiresIn}) {
    const Duration earlyTokenExpiry = Duration(seconds: 20);
    if (expiresIn <= earlyTokenExpiry) {
      return Duration.zero;
    }
    return expiresIn - earlyTokenExpiry;
  }
}

class FcmAccessTokenManager extends AccessTokenManager {
  FcmAccessTokenManager({
    required FcmTokenDto token,
    required JwtBuilder jwtBuilder,
    required http.Client httpClient,
    required Uri tokenUri,
  })  : _token = token,
        _jwtBuilder = jwtBuilder,
        _httpClient = httpClient,
        _tokenUri = tokenUri;

  final FcmTokenDto _token;
  final JwtBuilder _jwtBuilder;
  final http.Client _httpClient;
  final Uri _tokenUri;

  @protected
  @override
  Future<AccessTokenResponse> fetchAccessToken() async {
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    final updatedTokenDto = _token.reissue();

    final builtJwtToken = _jwtBuilder.buildToken(updatedTokenDto);

    final body = {
      'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      'assertion': builtJwtToken,
    };

    final response =
        await _httpClient.post(_tokenUri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw AccessTokenManagerException(
        'Error statusCode: ${response.statusCode}',
        details: response.body,
      );
    }

    return AccessTokenResponse.fromJson(response.body);
  }
}

class AccessTokenResponse {
  AccessTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.scope,
  });

  final String accessToken;
  final String? scope;
  final String tokenType;
  final Duration expiresIn;

  factory AccessTokenResponse.fromMap(Map<String, dynamic> map) {
    try {
      return AccessTokenResponse(
        accessToken: map['access_token'] as String,
        scope: map['scope'] != null ? map['scope'] as String : null,
        tokenType: map['token_type'] as String,
        expiresIn: Duration(seconds: map['expires_in'] as int),
      );
    } on TypeError catch (e, stackTrace) {
      throw WrongFormatAccessTokenResponseException(
          'Wrong access code response format',
          details: e,
          stackTrace: stackTrace);
    }
  }

  factory AccessTokenResponse.fromJson(String source) =>
      AccessTokenResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AccessTokenResponse(accessToken: $accessToken, scope: $scope, tokenType: $tokenType, expiresIn: $expiresIn)';
  }
}
