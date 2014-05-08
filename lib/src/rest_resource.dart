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

  Future<String> Trigger(HttpRequest request, ContentType type, String path) {
    return new Future.sync(() {
      this._SendAllowedMethods(request.response);
      if (request.method == HTTP_OPTIONS) {
        return null;
      }
      if (!this._handlers.containsKey(request.method)) {
        throw new RestException(405, "The method " + request.method + " is not allowed for this resource");
      }

      return this._handlers[request.method](type, path, request.uri.queryParameters).then((result) {
        if (result == null) {
          return "";
        } else {
          return result.toString();
        }
      });
    });
  }
}
