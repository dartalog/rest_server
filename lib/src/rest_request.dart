part of rest;

class RestRequest {
  final Logger _log = new Logger('RestRequest');
  final HttpRequest httpRequest;  
  final RestServer _server;
  final Map<String, RestRange> ranges = new Map<String, RestRange>();
  
  RestResponse response;
  
  Match regexMatch = null;
  
  AcceptCollection acceptableContentTypes;

  BytesBuilder data = new BytesBuilder();

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
  
  void set requestedContentType(ContentType type) {
    this.httpRequest.response.headers.contentType = type;
  }

  ContentType get dataContentType {
    return this.httpRequest.headers.contentType;
  }

  
  RestRequest(this._server, this.httpRequest) {
    // Break down the accept request
    acceptableContentTypes = new AcceptCollection(HttpHeaders.ACCEPT,this.httpRequest);
    this.response = new RestResponse(this.httpRequest.response);
    
    
    String ranges = this.httpRequest.headers.value(HttpHeaders.RANGE);
  }
  
  Future loadData() {
    Completer completer = new Completer();
    this.httpRequest.listen((List<int> buffer) {
      this.data.add(buffer);
    }, onDone: () {
      if(this.data.length>0 && this.dataContentType == null) {
        completer.completeError(new RestException(HttpStatus.UNSUPPORTED_MEDIA_TYPE,"No ${HttpHeaders.CONTENT_TYPE} was specified"));        
      } else {
        completer.complete();
      }
    });
    return completer.future;
  }
  
  String getDataAsString() {
    return convert.UTF8.decode(this.data.takeBytes());
  }
}