part of rest;

/// HTTP methods, as defined at [http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html].
abstract class HttpMethod {
  static const String CONNECT = "CONNECT";
  static const String DELETE = "DELETE";
  static const String GET = "GET";
  static const String HEAD = "HEAD";
  static const String OPTIONS = "OPTIONS";
  static const String POST = "POST";
  static const String PUT = "PUT";
  static const String TRACE = "TRACE";
}