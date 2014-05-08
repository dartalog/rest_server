part of rest;

class _RestContentTypes {
  List<ContentType> _ContentTypes = new List<ContentType>();
  ContentType _Default = null;


  void AddDefaultContentType(ContentType type) {
    this._Default = type;
    this.AddContentType(type);
  }

  void AddContentType(ContentType type) {
    if (!this._ContentTypes.contains(type)) {
      this._ContentTypes.add(type);
    }
  }


  ContentType GetRequestedContentType(HttpRequest request) {

    if (this._Default == null) {
      throw new RestException(500, "No default content type configured");
    }
    if (this._ContentTypes.length == 0) {
      throw new RestException(500, "No content types configured");
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
        throw new RestException(406, "Invalid content type specified in Accept request header", e);
      }
      throw new RestException(406, "Requested content type(s) not supported");
    } else {
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
