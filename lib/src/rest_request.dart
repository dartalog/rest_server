part of rest;

class RestRequest {
  final Logger _log = new Logger('RestRequest');
  final HttpRequest httpRequest;  
  final RestServer _server;
  
  String get method {
    return this.httpRequest.method;
  }
  String get path {
    return this.httpRequest.uri.path;
  }
  Map<String, String> get args { 
    return this.httpRequest.uri.queryParameters;
  }

  
  ContentType get requestedContentType {
    return this.httpRequest.response.headers.contentType;
  }

  ContentType get dataContentType {
    return this.httpRequest.headers.contentType;
  }

  AcceptCollection acceptableContentTypes;

  List<int> data = new List<int>();
  
  RestRequest(this._server, this.httpRequest) {
    // Break down the accept request
    acceptableContentTypes = new AcceptCollection(this.httpRequest.headers.value(HttpHeaders.ACCEPT));
  }
  
  Future loadData() {
    Completer completer = new Completer();
    this.httpRequest.listen((List<int> buffer) {
      this.data.addAll(buffer);
    }, onDone: () {
      if(this.data.length>0 && this.dataContentType == null) {
        completer.completeError(new RestException(HttpStatus.UNSUPPORTED_MEDIA_TYPE,"No ${HttpHeaders.CONTENT_TYPE} was specified"));        
      } else {
        completer.complete();
      }
    });
    return completer.future;
  }
}