part of rest;

class RestResponse {
  final HttpResponse httpResponse;
  final Map<String,RestRange> ranges = new Map<String,RestRange>();
  
  RestResponse(this.httpResponse);
}