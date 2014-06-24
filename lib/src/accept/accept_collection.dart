part of rest;

class AcceptCollection  {
  final Logger _log = new Logger('AcceptCollection');

  final List<AThingToAccept> items = new List<AThingToAccept>();

  static const String _ACCEPT_HEADER_REGEX = "([^,;]+)((;[^;^,]+)*)";
  static final RegExp _acceptHeaderRegexp = new RegExp(_ACCEPT_HEADER_REGEX);

  AcceptCollection(String header_name, HttpRequest request) {
    for (String header in request.headers[header_name]) {
      for (String value in header.split(",")) {
        AThingToAccept thing;
        switch (header_name) {
          case HttpHeaders.ACCEPT:
            thing = new AcceptContentType(value);
            break;
          default:
            this._log.warning("Header not known: ${header_name}");
            continue;
        }
        this.items.add(thing);
      }
    }
    this.items.sort();

    for(AThingToAccept thing in this.items) {
      this._log.info(thing.toString());
      
    }
    // Now, we 
    
    //    Iterable<Match> matches = _acceptHeaderRegexp.allMatches(accept_header);
    //    if (matches.length > 0) {
    //      for (Match match in matches) {
    //        // Group 1 should be the request
    //        // Group 2 should be the arguments
    //
    //        //String content_type = match.group(1);
    //
    //        if (match.group(2).trim() != "") {
    //          AThingToAccept thing;
    //          switch(header_name) {
    //            case HttpHeaders.ACCEPT:
    //              thing = new AcceptContentType(match.group(0));
    //              break;
    //            default:
    //              this._log.warning("Header not known: ${header_name}");
    //              continue;
    //          }
    //
    //
    //
    //          if(!this.acceptContentTypes.containsKey(thing.quality)) {
    //            AcceptSubCollection sub = new AcceptSubCollection();
    //            this.acceptContentTypes[thing.quality] = sub;
    //
    //          }
    //
    //        }
    //
    //      }
    //}
  }
  
}
