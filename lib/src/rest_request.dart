part of rest;

class RestRequest {
  HttpRequest httpRequest;
  ContentType requestedContentType;
  String path;
  Map<String, String> args;

  ContentType dataContentType;
  List<int> data = new List<int>();
  
  RestRequest(this.httpRequest) {
    this.requestedContentType = this.httpRequest.response.headers.contentType;
    this.path = this.httpRequest.uri.path;
    this.args = this.httpRequest.uri.queryParameters;
    this.dataContentType = this.httpRequest.headers.contentType;
  }
  
  Future loadData() {
    Completer completer = new Completer();
    this.httpRequest.listen((List<int> buffer) {
      this.data.addAll(buffer);
    }, onDone: () {
      completer.complete();
    });
    return completer.future;
  }
}