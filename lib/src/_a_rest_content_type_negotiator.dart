part of rest;


abstract class _ARestContentTypeNegotiator {
  final Logger _a_log = new Logger('_ARestContentTypeNegotiator');
  
  Map<String, List<ContentType>> _availableContentTypes = new Map<String, List<ContentType>>();
  Map<String, List<ContentType>> _acceptableContentTypes = new Map<String, List<ContentType>>();
  Map<String, ContentType> _defaultAvailable = new Map<String, ContentType>();

  ManualContentTypeProvider manualAvailableContentTypes = null;
  ManualContentTypeProvider manualAcceptableContentTypes = null;

  bool ignoreGlobalContentTypes = false;
  RestServer _rest_server;

  void addDefaultAvailableContentType(ContentType type, [String method = _GLOBAL_METHOD]) {
    this._defaultAvailable[method] = type;
    this.addAvailableContentType(type, method);
  }

  void addAvailableContentType(ContentType type, [String method = _GLOBAL_METHOD]) {
    if (!this._availableContentTypes.containsKey(method)) {
      this._availableContentTypes[method] = new List<ContentType>();
    }

    if (!this._availableContentTypes[method].contains(type)) {
      this._availableContentTypes[method].add(type);
    }
  }

  void addAcceptableContentType(ContentType type, [String method = _GLOBAL_METHOD]) {
    if (!this._acceptableContentTypes.containsKey(method)) {
      this._acceptableContentTypes[method] = new List<ContentType>();
    }

    if (!this._acceptableContentTypes[method].contains(type)) {
      this._acceptableContentTypes[method].add(type);
    }
  }



  Future _handleContentTypes(RestRequest request) {
    // First we check if the submitted data is in a format that the resource understands
    return this._checkAcceptableContentTypes(request).then((_) {
      return this._handleAvailableContentTypes(request);
    });
  }

  Future _checkAcceptableContentTypes(RestRequest request) {
    return new Future.sync(() {
      if (request.data.length > 0) { // If there is data submitted (we check for the presence of a content-type in RestRequest)
        return new Future.sync(() {
          // Check the manual provider first
          if (this.manualAcceptableContentTypes != null) {
            return this.manualAcceptableContentTypes(request);
          }
        }).then((List<ContentType> manual_types) {
          ContentType type = null;
          // Check against the manual content types
          if(manual_types!=null) {
            type =_findMatchingContentType(manual_types, request.dataContentType, false);
          }

          // Check against the resource's method-specific content types
          if (type == null && this._acceptableContentTypes.containsKey(request.method)) {
            type = _findMatchingContentType(this._acceptableContentTypes[request.method], request.dataContentType, false);
          }

          // Check against the resource's global content types
          if (type == null && this._acceptableContentTypes.containsKey(_GLOBAL_METHOD)) {
            type = _findMatchingContentType(this._acceptableContentTypes[_GLOBAL_METHOD], request.dataContentType, false);
          }

          // Check against the server's method-specific content types
          if (type == null && request._server._acceptableContentTypes.containsKey(request.method)) {
            type = _findMatchingContentType(request._server._acceptableContentTypes[request.method], request.dataContentType, false);
          }

          // Check against the server's global content types
          if (type == null && request._server._acceptableContentTypes.containsKey(_GLOBAL_METHOD)) {
            type = _findMatchingContentType(request._server._acceptableContentTypes[_GLOBAL_METHOD], request.dataContentType, false);
          }

          if (type == null) {
            throw new RestException(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "Unsupported content type: " + request.dataContentType.toString());
          }
        });
      }
    });
  }


  ContentType _findDefaultContentType(String method, AcceptContentType requested_type) {
    if (this._defaultAvailable.containsKey(method)) {
      return this._defaultAvailable[method];
    } else if (this._defaultAvailable.containsKey(_GLOBAL_METHOD)) {
      return this._defaultAvailable[_GLOBAL_METHOD];
    } else if (!this.ignoreGlobalContentTypes&&this._rest_server._defaultAvailable.containsKey(method)) {
      return this._rest_server._defaultAvailable[method];
    } else if (!this.ignoreGlobalContentTypes&&this._rest_server._defaultAvailable.containsKey(_GLOBAL_METHOD)) {
      return this._rest_server._defaultAvailable[_GLOBAL_METHOD];
    } else {
      return null;
    }

  }

  Future _handleAvailableContentTypes(RestRequest request) {
    ContentType output = null;
    List<ContentType> available_types = new List<ContentType>();

    return new Future.sync(() {
      
      
      if (request.acceptableContentTypes.items.length == 0) { // No requested type
        output = _findDefaultContentType(request.method, new AcceptContentType("*/*"));
        if (output == null) {
          throw new RestException(HttpStatus.NOT_ACCEPTABLE, "No Accept header found, and no default content type has been specified on the server");
        } else {
          this._a_log.info("No content type requested, using default: ${output.toString()}");
          request.requestedContentType = output;
          return output;
        }
      }

      if (this._availableContentTypes.containsKey(request.method)) {
        available_types.addAll(this._availableContentTypes[request.method]);
      }
      if (this._availableContentTypes.containsKey(_GLOBAL_METHOD)) {
        available_types.addAll(this._availableContentTypes[_GLOBAL_METHOD]);
      }
      if (this.manualAvailableContentTypes != null) {
        return this.manualAvailableContentTypes(request).then((result) {
          available_types.addAll(result);
        });
      }
    }).then((_) { 
        if(!this.ignoreGlobalContentTypes) {
          if (this._rest_server._availableContentTypes.containsKey(request.method)) {
            available_types.addAll(this._rest_server._availableContentTypes[request.method]);
          }
          if (this._rest_server._availableContentTypes.containsKey(_GLOBAL_METHOD)) {
            available_types.addAll(this._rest_server._availableContentTypes[_GLOBAL_METHOD]);
          }
        }
        
        if(available_types.length==0) {
          throw new RestException(HttpStatus.INTERNAL_SERVER_ERROR,"There are no content types configured for this resource via this method");
        }

        
        for (AcceptContentType requested_type in request.acceptableContentTypes.items) {
          if(requested_type.qualification<=AThingToAccept._PARTIALLY_QUALIFIED) {
            output = _findDefaultContentType(request.method, requested_type);
            if(output!=null) {
              this._a_log.info("${requested_type.toString()} matched against ${output.toString()}");
              break;
            }
          }
          
          for (ContentType available_type in available_types) {              
            if (requested_type.matches(available_type)) { 
              this._a_log.info("${requested_type.toString()} matched against ${available_type.toString()}");
              output = available_type;
              break;
            }
          }
          if(output!=null) {
            break;
          }
        }
        
        if (output == null) {
          throw new RestException(HttpStatus.NOT_ACCEPTABLE, "No content type matching the Accept header is available");
        } else {
          request.requestedContentType = output;
          return output;
        }
    });

    //      if (this._availableContentTypes.length == 0) {
    //        throw new RestException(HttpStatus.INTERNAL_SERVER_ERROR, "No content types configured");
    //      }
    //
    //
    //      // First we need to determine what content type to generate
    //      String requested_content_type = request.headers.value("Accept");
    //
    //      if (requested_content_type != null && requested_content_type != "") {
    //        try {
    //          ContentType ct = null;
    //          // TODO: Implement the accept quality thingamabob
    //          // TODO: Implement more specific content types getting higher priority
    //          for (String type_string in requested_content_type.split(',')) {
    //            ContentType req_ct = ContentType.parse(type_string);
    //            ct = this._MatchContentType(req_ct);
    //            if (ct != null) {
    //              return ct;
    //            }
    //          }
    //        } catch (e, st) {
    //          throw new RestException(HttpStatus.NOT_ACCEPTABLE, "Invalid content type specified in Accept request header", e);
    //        }
    //        throw new RestException(HttpStatus.NOT_ACCEPTABLE, "Requested content type(s) not supported");
    //      } else {
    //        if()
    //
    //        return this._default;
    //      }

  }

  static ContentType _findMatchingContentType(List<ContentType> ct_pool, ContentType req_ct, bool allow_wildcards) {
    
    for (ContentType ct in ct_pool) {
      if ((!allow_wildcards || req_ct.primaryType != "*") && req_ct.primaryType != ct.primaryType) {
        continue;
      }
      if ((!allow_wildcards || req_ct.subType != "*") && req_ct.subType != ct.subType) {
        continue;
      }
      return ct;
    }

    return null;
  }
}
