class HttpException implements Exception {
  // here we want to add error message

  final String _message;
  HttpException(this._message);

  @override
  String toString() {
    if (_message == null) return 'Exception';
    return _message;
  }
}
