part of rest;

class RestResponse {
  final HttpResponse httpResponse;
  RestRange _range = null;
  
  RestResponse(this.httpResponse);
  
  void setRange(String name, int start, int end, int total) {
    this._range = new RestRange._fromValues(name, start, end, total);
  }
  
}