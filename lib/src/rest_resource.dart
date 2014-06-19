part of rest;

class RestResource extends _ARestContentTypeNegotiator {

  String method;

  RegExp _regex;

  RestServer _server;

  Map<String, RestResourceMethodHandler> _handlers = new Map<String, RestResourceMethodHandler>();
  
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
    return new Future.sync(() {
      
    });
  }
  
  Future<String> _trigger(RestRequest request) {
    return new Future.sync(() {
      this._sendAllowedMethods(request.httpRequest.response);
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
