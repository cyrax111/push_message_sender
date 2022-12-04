import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jwt_manager/jwt_manager.dart';
import 'package:meta/meta.dart';

import 'access_token_manager.dart';
import 'fcm_access_token_manager_exception.dart';

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
      throw FcmAccessTokenManagerException(
        'Error statusCode: ${response.statusCode}',
        details: response.body,
      );
    }

    return FcmAccessTokenResponse.fromJson(response.body);
  }
}

/// Access token DTO
class FcmAccessTokenResponse implements AccessTokenResponse {
  FcmAccessTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.scope,
  });

  @override
  final String accessToken;
  final String? scope;
  final String tokenType;
  @override
  final Duration expiresIn;

  factory FcmAccessTokenResponse.fromMap(Map<String, dynamic> map) {
    try {
      return FcmAccessTokenResponse(
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

  factory FcmAccessTokenResponse.fromJson(String source) =>
      FcmAccessTokenResponse.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AccessTokenResponse(accessToken: $accessToken, scope: $scope, tokenType: $tokenType, expiresIn: $expiresIn)';
  }
}
