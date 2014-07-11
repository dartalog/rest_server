part of rest;

class RestRange {
  String name;
  int start;
  int end;
  int total;
  
  void setHeaders(HttpRequest req) {
    req.response.headers.add(HttpHeaders.ACCEPT_RANGES, name);
    req.response.headers.add(HttpHeaders.CONTENT_RANGE, "${name} ${start}-${end}");
  }
}