part of rest;

class RestResource {

  String Method;

  RegExp _regex;


  Map<String, ARestEventHandler> _handlers = new Map<String, ARestEventHandler>();

  RestResource(String regex) {
    _regex = new RegExp(regex);
  }

  void SetHandlerResource(String method, ARestEventHandler handler) {
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

  Future<String> Trigger(HttpRequest request, ContentType type, String path) {
    return new Future.sync(() {
      this._SendAllowedMethods(request.response);
      if (request.method == HTTP_OPTIONS) {
        return null;
      }
      if (!this._handlers.containsKey(request.method)) {
        throw new RestException(405, "The method " + request.method + " is not allowed for this resource");
      }

      return this._handlers[request.method].Trigger(type, path, request.uri.queryParameters).then((result) {
        if (result == null) {
          return "";
        } else {
          return result.toString();
        }
      });
    });
  }
}
