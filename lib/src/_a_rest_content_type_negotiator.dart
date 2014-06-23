part of rest;


abstract class _ARestContentTypeNegotiator {
  Map<String,List<ContentType>> _availableContentTypes = new Map<String,List<ContentType>>();
  Map<String,List<ContentType>> _acceptableContentTypes = new Map<String,List<ContentType>>();
  Map<String,ContentType> _defaultAvailable = new Map<String,ContentType>();

  ManualContentTypeProvider manualAvailableContentTypes = null;
  ManualContentTypeProvider manualAcceptableContentTypes = null;

  bool _ignoreGlobalContentTypes = false;

  static String _GLOBAL_METHOD = "GLOBAL";
  
  void addDefaultAvailableContentType(ContentType type, [String method = "GLOBAL"]) {
    this._defaultAvailable[method] = type;
    this.addAvailableContentType(type,method);
  }

  void addAvailableContentType(ContentType type, [String method = "GLOBAL"]) {
    if(!this._availableContentTypes.containsKey(method)) {
      this._availableContentTypes[method] = new List<ContentType>();
    }
    
    if (!this._availableContentTypes[method].contains(type)) {
      this._availableContentTypes[method].add(type);
    }
  }
  
  void addAcceptableContentType(ContentType type, [String method = "GLOBAL"]) {
    if(!this._acceptableContentTypes.containsKey(method)) {
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
        if(request.data.length>0) { // If there is data submitted (we check for the presence of a content-type in RestRequest)
          return new Future.sync(() {
          // Check the manual provider first
            if(this.manualAcceptableContentTypes!=null) {
              return this.manualAcceptableContentTypes(request);
            }
          }).then((List<ContentType> manual_types) {
            // Check against the manual content types
            ContentType type = _findMatchingContentType(manual_types, request.dataContentType, false);
            
            // Check against the resource's method-specific content types
            if(type==null && this._acceptableContentTypes.containsKey(request.method)) {
              type = _findMatchingContentType(this._acceptableContentTypes[request.method], request.dataContentType,false);
            }
            
            // Check against the resource's global content types
            if(type==null && this._acceptableContentTypes.containsKey(_GLOBAL_METHOD)) {
              type = _findMatchingContentType(this._acceptableContentTypes[_GLOBAL_METHOD], request.dataContentType,false);
            }
            
            // Check against the server's method-specific content types
            if(type==null && request._server._acceptableContentTypes.containsKey(request.method)) {
              type = _findMatchingContentType(request._server._acceptableContentTypes[request.method], request.dataContentType,false);
            }
            
            // Check against the server's global content types
            if(type==null && request._server._acceptableContentTypes.containsKey(_GLOBAL_METHOD)) {
              type = _findMatchingContentType(request._server._acceptableContentTypes[_GLOBAL_METHOD], request.dataContentType,false);
            }
            
            if(type==null) {
              throw new RestException(HttpStatus.UNSUPPORTED_MEDIA_TYPE,"Unsupported content type");
            }
          });
        }
      });
    }

   
    
    Future _handleAvailableContentTypes(RestRequest request) {
      return new Future.sync(() {
        
        
        
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