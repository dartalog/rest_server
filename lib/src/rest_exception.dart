part of rest;

/**
 * An object representing a REST error with HTTP code and message to be sent to the requester.
 */
class RestException implements Exception {
  /// The HTTP status code to be sent to the requester.
  final int Code;
  /// The message to be sent to the requester.
  final String Message;
  /// The original [Exception] that caused the REST exception (if any).
  final Exception InnerException;

  /**
   * Creates a [RestException] containing the specified values. 
   */ 
  RestException(this.Code, this.Message, [this.InnerException = null]);

  @override
  String toString() {
    return this.Message;
  }
}
