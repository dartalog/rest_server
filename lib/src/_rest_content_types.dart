part of rest;

class _RestContentTypes {
  Map<String,List<ContentType>> _AvailableContentTypes = new Map<String,List<ContentType>>();
  Map<String,List<ContentType>> _AcceptableContentTypes = new Map<String,List<ContentType>>();
  Map<String,ContentType> _DefaultAvailable = null;


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
  
  ManualAvailableContentTypes manualAvailableContentTypes = null;
  ManualAcceptableContentTypes manualAcceptableContentTypes = null;

  
  void handleContentTypes(HttpRequest request, RestResource resource) {
    
    
    
    if (resource._DefaultAvailableContentType == null && this._Default == null) {
      throw new RestException(HttpStatus.INTERNAL_SERVER_ERROR, "No default content type configured");
    }
    if (this._ContentTypes.length == 0) {
      throw new RestException(HttpStatus.INTERNAL_SERVER_ERROR, "No content types configured");
    }


    // First we need to determine what content type to generate
    String requested_content_type = request.headers.value("Accept");

    if (requested_content_type != null && requested_content_type != "") {
      try {
        ContentType ct = null;
        // TODO: Implement the accept quality thingamabob
        // TODO: Implement more specific content types getting higher priority
        for (String type_string in requested_content_type.split(',')) {
          ContentType req_ct = ContentType.parse(type_string);
          ct = this._MatchContentType(req_ct);
          if (ct != null) {
            return ct;
          }
        }
      } catch (e, st) {
        throw new RestException(HttpStatus.NOT_ACCEPTABLE, "Invalid content type specified in Accept request header", e);
      }
      throw new RestException(HttpStatus.NOT_ACCEPTABLE, "Requested content type(s) not supported");
    } else {
      if()
      
      return this._Default;
    }
  }


  
  ContentType _MatchContentType(ContentType req_ct) {
    if (req_ct.primaryType == "*" && req_ct.subType == "*") {
      return this._Default;
    }

    for (ContentType ct in this._ContentTypes) {
      if (req_ct.primaryType != "*" && req_ct.primaryType != ct.primaryType) {
        continue;
      }
      if (req_ct.subType != "*" && req_ct.subType != ct.subType) {
        continue;
      }
      return ct;
    }

    return null;
  }
}
