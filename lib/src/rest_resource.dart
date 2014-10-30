part of rest;

class RestResource extends _ARestContentTypeNegotiator {
  RegExp _regex;
  RestServer _server;

  final Map<String, RestResourceMethodHandler> _handlers = new Map<String, RestResourceMethodHandler>();
  final List<String> _acceptRanges = new List<String>();
  
  RestResource(String regex) {
    _regex = new RegExp(regex);
  }

  void setMethodHandler(String method, RestResourceMethodHandler handler) {
    this._handlers[method] = handler;
  }

  void addAcceptRange(String name) {
    this._acceptRanges.add(name);
  }
  
  Match _matches(String resource) {
    if(this._regex.hasMatch(resource)) {
      return this._regex.firstMatch(resource);
    }
    return null;
  }

  void _sendAllowedMethods(HttpResponse response) {
    StringBuffer methods = new StringBuffer();
    methods.write(HttpMethod.OPTIONS);
    for (String method in this._handlers.keys) {
      methods.write(",");
      methods.write(method);
    }

    response.headers.add(HttpHeaders.ALLOW, methods.toString());
    response.headers.add(AccessHeaders.ACCESS_CONTROL_ALLOW_METHODS, methods.toString());
  }

  
  Future _processHeaders(RestRequest request) {
    return new Future(() {
      
    });
  }
  
  Future _trigger(RestRequest request) {
    return new Future(() {
      
      this._sendAllowedMethods(request.httpRequest.response);
      
      if (request.httpRequest.method == HttpMethod.OPTIONS) {
        return null;
      }
      
      for(String range in this._acceptRanges) {
        request.response.httpResponse.headers.add(HttpHeaders.ACCEPT_RANGES, range);
      }
     
      if (!this._handlers.containsKey(request.httpRequest.method)) {
        throw new RestException(HttpStatus.METHOD_NOT_ALLOWED, "The method " + request.httpRequest.method + " is not allowed for this resource");
      }
      
      if(request.range!=null) {
        if(this._acceptRanges.length==0) {
          throw new RestException(HttpStatus.BAD_REQUEST,"The Range header is not supported for this resource");
        } else if(!this._acceptRanges.contains(request.range.name)) {
          throw new RestException(HttpStatus.BAD_REQUEST,"The requested range is not supported");
        }
      }
      
      return request._loadData().then((_) {
        return this._handleContentTypes(request);
      }).then((_) {
        Future fut = this._handlers[request.httpRequest.method](request);
        if(fut==null) {
          throw new RestException(HttpStatus.INTERNAL_SERVER_ERROR,"Request handler did not return a Future");
        }
        return fut.then((result) {
          
          if(request.response._range!=null) {
            request.response._range._setResponseHeaders(request.httpRequest);
          }
          
          if (result == null) {
            return "";
          } else {
            return result;
          }
        });
      });
    });
  }
}
