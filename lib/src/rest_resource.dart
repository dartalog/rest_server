part of rest;

class RestResource {

  String method;

  RegExp _regex;

  RestServer _server;

  Map<String, RestResourceMethodHandler> _handlers = new Map<String, RestResourceMethodHandler>();
  
  // BEGIN Content Type handlers
  bool ignoreGlobalContentTypes = false;
  
  
  Map<String,List<ContentType>> _availableContentTypes = new Map<String,List<ContentType>>();
  Map<String,List<ContentType>> _acceptableContentTypes = new Map<String,List<ContentType>>();
  Map<String,ContentType> _defaultAvailable = null;
  
  ManualAvailableContentTypes manualAvailableContentTypes = null;
  ManualAcceptableContentTypes manualAcceptableContentTypes = null;
  
  void addDefaultAvailableContentType(ContentType type, [String method = "GLOBAL"]) {
    this._defaultAvailable[method] = type;
    this.addAvailableContentType(type,method);
  }

  void addAvailableContentType(ContentType type, [String method = "GLOBAL"]) {
    if(!this._availableContentTypes.containsKey(method)) {
      this._availableContentTypes[method] = new List<ContentType>();
    }
    
    if (!this._availableContentTypes[method].contains(type)) {
      this._availableContentTypes[method].add(type);
    }
  }
  
  void addAcceptableContentType(ContentType type, [String method = "GLOBAL"]) {
    if(!this._acceptableContentTypes.containsKey(method)) {
      this._acceptableContentTypes[method] = new List<ContentType>();
    }
    
    if (!this._acceptableContentTypes[method].contains(type)) {
      this._acceptableContentTypes[method].add(type);
    }
  }
  
  // END Content Type handlers
  
  
  RestResource(String regex) {
    _regex = new RegExp(regex);
  }

  void setMethodHandler(String method, RestResourceMethodHandler handler) {
    this._handlers[method] = handler;
  }

  bool _matches(String resource) {
    return this._regex.hasMatch(resource);
  }

  void _sendAllowedMethods(HttpResponse response) {
    StringBuffer methods = new StringBuffer();
    methods.write("OPTIONS");
    for (String method in this._handlers.keys) {
      methods.write(",");
      methods.write(method);
    }

    response.headers.add("Allow", methods.toString());
    response.headers.add("Access-Control-Allow-Methods", methods.toString());
  }

  
  Future _processHeaders(RestRequest request) {
    
  }
  
  Future<String> _trigger(RestRequest request) {
    return new Future.sync(() {
      this._SendAllowedMethods(request.httpRequest.response);
      if (request.httpRequest.method == HTTP_OPTIONS) {
        return null;
      }
     
      if (!this._handlers.containsKey(request.httpRequest.method)) {
        throw new RestException(HttpStatus.METHOD_NOT_ALLOWED, "The method " + request.httpRequest.method + " is not allowed for this resource");
      }
      
      return request.loadData().then((_) {
        return this._handlers[request.httpRequest.method](request).then((result) {
          if (result == null) {
            return "";
          } else {
            return result.toString();
          }
        });
      });
    });
  }
  
}
