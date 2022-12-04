import 'dart:async';

import 'package:emptyable_timer/emptyable_timer.dart';
import 'package:meta/meta.dart';

/// Keeps always the [accessToken] fresh
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

abstract class AccessTokenResponse {
  String get accessToken;
  Duration get expiresIn;
}
