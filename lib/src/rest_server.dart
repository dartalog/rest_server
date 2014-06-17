part of rest;

class RestServer {
  List<RestResource> _resources = new List<RestResource>();

  final Logger _log = new Logger('RestServer');

  _RestContentTypes _AvailableContentTypes = new _RestContentTypes();

  RestServer() {
    this._log.info("Rest server instance created");
  }

  void Start([InternetAddress address = null, int port = 8080]) {

    if (address == null) {
      address = InternetAddress.LOOPBACK_IP_V4;
    }

    HttpServer.bind(address, port).then((server) {
      this._log.info("Serving at ${server.address}:${server.port}");
      server.listen(_AnswerRequest);
    });

  }

  void AddDefaultContentType(ContentType type) {
    this._AvailableContentTypes.AddDefaultContentType(type);
  }

  void AddContentType(ContentType type) {
    this._AvailableContentTypes.AddContentType(type);
  }

  void AddResource(RestResource resource) {
    this._resources.add(resource);
  }

  void _AnswerRequest(HttpRequest http_request) {
    Stopwatch stopwatch = new Stopwatch()..start();
    StringBuffer output = new StringBuffer();
    Future fut = new Future.sync(() {
      http_request.response.headers.contentType = this._AvailableContentTypes.GetRequestedContentType(http_request);
      RestRequest request = new RestRequest(http_request);
      
      for (RestResource resource in this._resources) {
        if (resource.Matches(http_request.uri.path)) {
          return resource.Trigger(request);
        }
      }
      throw new RestException(404, "The requested resource was not found");
    }).then((data) {
      if (data != null) {
        output.write(data);
      }
    }).catchError((e, st) {
      this._log.severe(e.toString(), e, st);
      output.write(this._ProcessError(http_request.response, e, st));
    }).whenComplete(() {
      // Last chance to write a header, so we write the processing time
      http_request.response.headers.add("X-Processing-Time", stopwatch.elapsed.toString());
      http_request.response.headers.add("Access-Control-Allow-Origin", "*");
      if (output.length == 0) { // If the content length is 0, and if the current status code is 200, then we send a 204
        if (http_request.response.statusCode ==  200) {
          http_request.response.statusCode = HttpStatus.NO_CONTENT;
        }
      } else {
        http_request.response.contentLength = output.length;
        http_request.response.write(output);
      }
      http_request.response.close();
      stopwatch.stop();
    });
  }

  String _ProcessError(HttpResponse response, Object e, [StackTrace st = null]) {
    Map<String, Object> output = new Map<String, Object>();

    output["message"] = e.toString();
    if (e is RestException) {
      response.statusCode = e.Code;
      output["code"] = e.Code;
    } else {
      response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
      output["code"] = HttpStatus.INTERNAL_SERVER_ERROR;
    }
    if (st != null) {
      output["stack_trace"] = st.toString();
    }

    return JSON.encode(output);
  }

}
