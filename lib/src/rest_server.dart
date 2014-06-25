part of rest;

class RestServer extends _ARestContentTypeNegotiator {
  List<RestResource> _resources = new List<RestResource>();

  final Logger _log = new Logger('RestServer');

  RestServer() {
    this._log.info("Rest server instance created");
  }

  void start([InternetAddress address = null, int port = 8080]) {

    if (address == null) {
      address = InternetAddress.LOOPBACK_IP_V4;
    }

    HttpServer.bind(address, port).then((server) {
      this._log.info("Serving at ${server.address}:${server.port}");
      server.listen(_answerRequest);
    });
  }
  
  void addResource(RestResource resource) {
    this._resources.add(resource);
    resource._server = this;
    resource._rest_server = this;
  }

  void _answerRequest(HttpRequest http_request) {
    Stopwatch stopwatch = new Stopwatch()..start();
    StringBuffer output = new StringBuffer();
    Future fut = new Future.sync(() {
      RestRequest request = new RestRequest(this,http_request);
      
      for (RestResource resource in this._resources) {
        if (resource._matches(http_request.uri.path)) {
          return resource._trigger(request);
        }
      }
      throw new RestException(HttpStatus.NOT_FOUND, "The requested resource was not found");
    }).then((data) {
      if (data != null) {
        output.write(data);
      }
    }).catchError((e, st) {
      this._log.severe(e.toString(), e, st);
      output.write(this._processError(http_request.response, e, st));
    }).whenComplete(() {
      // Last chance to write a header, so we write the processing time
      http_request.response.headers.add("X-Processing-Time", stopwatch.elapsed.toString());
      http_request.response.headers.add("Access-Control-Allow-Origin", "*");
      if (output.length == 0) { // If the content length is 0, and if the current status code is 200, then we send a 204
        if (http_request.response.statusCode ==  HttpStatus.OK) {
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

  String _processError(HttpResponse response, Object e, [StackTrace st = null]) {
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
  
  Future determineContentType() {
    
  }

}
