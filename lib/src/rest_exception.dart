part of rest;

class RestException implements Exception {
  final int Code;
  final String Message;
  final Exception InnerException;

  RestException(this.Code, this.Message, [this.InnerException = null]);


  @override
  String toString() {
    return this.Message;
  }
}
