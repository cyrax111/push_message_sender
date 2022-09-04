class PushMessageSenderException implements Exception {
  PushMessageSenderException(this.message, {this.details, this.stackTrace});
  final String message;
  final Object? details;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final detailsStr = details == null ? '' : 'Details: $details';
    final stackTraceStr =
        stackTrace == null ? '' : 'Inner stacktrace:\n$stackTrace';
    return '$message\n$detailsStr\n$stackTraceStr';
  }
}
