part of rest;

class RestResource {

  String Method;

  RegExp _regex;


  Map<String, RestResourceMethodHandler> _handlers = new Map<String, RestResourceMethodHandler>();
  
  // BEGIN Content Type handlers
  bool ignoreGlobalContentTypes = false;
  Map<String,List<ContentType>> _AvailableContentTypes = new Map<String,List<ContentType>>();
  Map<String,List<ContentType>> _AcceptableContentTypes = new Map<String,List<ContentType>>();
  Map<String,ContentType> _DefaultAvailable = null;
  
  ManualAvailableContentTypes manualAvailableContentTypes = null;
  ManualAcceptableContentTypes manualAcceptableContentTypes = null;
  
  void addDefaultAvailableContentType(ContentType type, [String method = "GLOBAL"]) {
    this._DefaultAvailable[method] = type;
    this.addAvailableContentType(type,method);
  }

  void addAvailableContentType(ContentType type, [String method = "GLOBAL"]) {
    if(!this._AvailableContentTypes.containsKey(method)) {
      this._AvailableContentTypes[method] = new List<ContentType>();
    }
    
    if (!this._AvailableContentTypes[method].contains(type)) {
      this._AvailableContentTypes[method].add(type);
    }
  }
  
  void addAcceptableContentType(ContentType type, [String method = "GLOBAL"]) {
    if(!this._AcceptableContentTypes.containsKey(method)) {
      this._AcceptableContentTypes[method] = new List<ContentType>();
    }
    
    if (!this._AcceptableContentTypes[method].contains(type)) {
      this._AcceptableContentTypes[method].add(type);
    }
  }
  
  // END Content Type handlers
  
  
  RestResource(String regex) {
    _regex = new RegExp(regex);
  }

  void SetMethodHandler(String method, RestResourceMethodHandler handler) {
    this._handlers[method] = handler;
  }

  bool Matches(String resource) {
    return this._regex.hasMatch(resource);
  }

  void _SendAllowedMethods(HttpResponse response) {
    StringBuffer methods = new StringBuffer();
    methods.write("OPTIONS");
    for (String method in this._handlers.keys) {
      methods.write(",");
      methods.write(method);
    }

    response.headers.add("Allow", methods.toString());
    response.headers.add("Access-Control-Allow-Methods", methods.toString());
  }

  
  Future<String> Trigger(RestRequest request) {
    return new Future.sync(() {
      this._SendAllowedMethods(request.httpRequest.response);
      if (request.httpRequest.method == HTTP_OPTIONS) {
        return null;
      }
     
      if (!this._handlers.containsKey(request.httpRequest.method)) {
        throw new RestException(HttpStatus.METHOD_NOT_ALLOWED, "The method " + request.httpRequest.method + " is not allowed for this resource");
      }
      
      if(request.httpRequest.method == HTTP_POST) {
        return request.loadData().then((_) {
          return _Trigger(request);
        });
      } else {
        return _Trigger(request);
      }

      
    });
  }
  
  Future<String> _Trigger(RestRequest request) {
    return this._handlers[request.httpRequest.method](request).then((result) {
      if (result == null) {
        return "";
      } else {
        return result.toString();
      }
    });
  }
}
