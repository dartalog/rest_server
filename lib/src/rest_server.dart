part of rest;

class RestServer extends _ARestContentTypeNegotiator {
  final List<RestResource> _resources = new List<RestResource>();
  
  static final Logger _log = new Logger('RestServer');

  String accessControlAllowOrigin = null;
  String accessControlAllowHeaders = null;
  String accessControlExposeHeaders = null;
  
  bool outputStackTrace = true;
  
  RestServer() {
    _log.info("Rest server instance created");
  }

  void start({InternetAddress address: null, int port: 8080}) {
    runZoned(() {
      if (address == null) {
        address = InternetAddress.LOOPBACK_IP_V4;
      }
  
      HttpServer.bind(address, port).then((server) {
        _log.info("Serving at ${server.address}:${server.port}");
        server.listen(_answerRequest);
      });
    },
    onError: (e, stackTrace) => _log.severe("Uncaught Exception: " + e.toString(), stackTrace));
  }
  
  void addResource(RestResource resource) {
    this._resources.add(resource);
    resource._server = this;
    resource._rest_server = this;
  }

  _answerRequest(HttpRequest http_request) async {
    Stopwatch stopwatch = new Stopwatch()..start();
    StringBuffer string_output = new StringBuffer();
    List<int> binary_output = new List<int>();
    RestRequest request;
    try {
      
      request = new RestRequest(this,http_request);
        
      dynamic data;
      for (RestResource resource in this._resources) {
        Match match = resource._matches(http_request.uri.path); 
        if (match!=null) {
          request.regexMatch = match;
          data = await resource._trigger(request);
          break;
        }
      }
      if (request.regexMatch==null) {
        throw new RestException(HttpStatus.NOT_FOUND, "The requested resource was not found: ${http_request.uri.path}");
      }
    
      if (data != null) {
        if(data is List<int>) {
          binary_output.addAll(data);
        } else {
          string_output.write(data);
        }
      }
    } catch(e, st) {
      _log.severe(e.toString(), e, st);
      string_output.write(this._outputError(http_request, e, st));
    } finally {
      _log.info("Writing headers");
      
      if(!_isNullOrEmpty(this.accessControlAllowOrigin)) {
        _log.info("Setting ${AccessHeaders.ACCESS_CONTROL_ALLOW_ORIGIN} header to \"${this.accessControlAllowOrigin}\"");
        http_request.response.headers.add(AccessHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, 
                                            this.accessControlAllowOrigin);
      }
      if(!_isNullOrEmpty(this.accessControlAllowHeaders)) {
        _log.info("Setting ${AccessHeaders.ACCESS_CONTROL_ALLOW_HEADERS} header to \"${this.accessControlAllowHeaders}\"");
        http_request.response.headers.add(AccessHeaders.ACCESS_CONTROL_ALLOW_HEADERS, 
                                            this.accessControlAllowHeaders);
      }
      if(!_isNullOrEmpty(this.accessControlExposeHeaders)) {
        _log.info("Setting ${AccessHeaders.ACCESS_CONTROL_EXPOSE_HEADERS} header to \"${this.accessControlExposeHeaders}\"");
        http_request.response.headers.add(AccessHeaders.ACCESS_CONTROL_EXPOSE_HEADERS, 
                                            this.accessControlExposeHeaders);
      }
      
      if (http_request.response.statusCode ==  HttpStatus.OK) {
        if(request.range!=null) {
          http_request.response.statusCode = HttpStatus.PARTIAL_CONTENT;
        }
      }
      
      // Last chance to write a header, so we write the processing time
      http_request.response.headers.add("X-Processing-Time", stopwatch.elapsed.toString());

      _log.info("Done writing headers");
      
      if(http_request.method==HttpMethod.HEAD) {
        _log.info("HEAD requested, not outputting content");
      } 
      
      if (binary_output.length == 0 && string_output.length == 0) { 
        // If the content length is 0, and if the current status code is 200, then we send a 204
        if (http_request.response.statusCode ==  HttpStatus.OK) {
          http_request.response.statusCode = HttpStatus.NO_CONTENT;
        }
      } else if(binary_output.length > 0) {
          _log.info("Writing binary output, total length: ${binary_output.length}");
          http_request.response.contentLength = binary_output.length;
          if(http_request.method!=HttpMethod.HEAD) {
            http_request.response.add(binary_output);
          }
      } else {
          _log.info("Writing string output, total length: ${string_output.length}");
          http_request.response.contentLength = string_output.length;
          if(http_request.method!=HttpMethod.HEAD) {
            http_request.response.write(string_output);
          }
      }

      _log.info("Response complete, closing");
      http_request.response.close();
      stopwatch.stop();
      _log.info("Response closed");
      _log.info("Response Code: ${http_request.response.statusCode}");
      _log.info("Total processing time: ${stopwatch.elapsed.toString()}");
    }
  }

  String _outputError(HttpRequest request, Object e, [StackTrace st = null]) {
    if (e is RestException) {
      request.response.statusCode = e.Code;
    } else {
      request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    }
    
    return _outputErrorAsJSON(request.response, e, st);
  }
  
  String _outputErrorAsHTML(HttpResponse response, Object e, [StackTrace st = null]) {
    StringBuffer output = new StringBuffer();
    output.writeln("<!DOCTYPE html>");
    output.writeln("<html><head><meta charset=\"UTF-8\"><title>${response.statusCode} - ${e.toString()}</title></head><body><details>");
    output.writeln("<summary>${response.statusCode} - ${e.toString()}</summary>");
    if (outputStackTrace && st != null) {
      output.writeln("<p>${st.toString()}</p>");
    }
    response.headers.contentType = ContentType.HTML;
    
    output.writeln("</details></html>");
    return output.toString();
  }

  
  String _outputErrorAsText(HttpResponse response, Object e, [StackTrace st = null]) {
    StringBuffer output = new StringBuffer();

    output.writeln("Status Code: ${response.statusCode}");
    output.writeln("Error: ${e.toString()}");
    if (outputStackTrace && st != null) {
      output.writeln("Stack Trace:\n ${st.toString()}");
    }
    response.headers.contentType = ContentType.TEXT;
    
    return output.toString();
  }

  
  String _outputErrorAsJSON(HttpResponse response, Object e, [StackTrace st = null]) {
    Map<String, Object> output = new Map<String, Object>();

    output["message"] = e.toString();
    output["code"] = response.statusCode;

    if (outputStackTrace && st != null) {
      output["stack_trace"] = st.toString();
    }
    response.headers.contentType = ContentType.JSON;
    
    return convert.JSON.encode(output);
  }

}
