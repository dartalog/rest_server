part of rest;

class RestResource {

  String Method;

  RegExp _regex;


  Map<String, RestResourceMethod> _handlers = new Map<String, RestResourceMethod>();

  RestResource(String regex) {
    _regex = new RegExp(regex);
  }

  void SetMethodHandler(String method, RestResourceMethod handler) {
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
