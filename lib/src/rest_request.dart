part of rest;

class RestRequest {
  HttpRequest httpRequest;
  ContentType requestedContentType;
  String path;
  Map<String, String> args;
  String method;

  RestServer _server;
  
  ContentType dataContentType;
  List<int> data = new List<int>();
  
  RestRequest(this._server, this.httpRequest) {
    this.requestedContentType = this.httpRequest.response.headers.contentType;
    this.path = this.httpRequest.uri.path;
    this.args = this.httpRequest.uri.queryParameters;
    this.dataContentType = this.httpRequest.headers.contentType;
    this.method = this.httpRequest.method;
  }
  
  Future loadData() {
    Completer completer = new Completer();
    this.httpRequest.listen((List<int> buffer) {
      this.data.addAll(buffer);
    }, onDone: () {
      if(this.data.length>0 && this.dataContentType == null) {
        completer.completeError(new RestException(HttpStatus.UNSUPPORTED_MEDIA_TYPE,"No Content-Type was specified"));        
      } else {
        completer.complete();
      }
    });
    return completer.future;
  }
}