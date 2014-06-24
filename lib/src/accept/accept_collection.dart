part of rest;

class AcceptCollection {
  final Logger _log = new Logger('AcceptCollection');

  Map<double, AcceptSubCollection> acceptContentTypes = new Map<double, AcceptSubCollection>();

  static const String _ACCEPT_HEADER_REGEX = "([^,;]+)((;[^;^,]+)*)";
  static final RegExp _acceptHeaderRegexp = new RegExp(_ACCEPT_HEADER_REGEX);

  AcceptCollection(String accept_header) {
    Iterable<Match> matches = _acceptHeaderRegexp.allMatches(accept_header);
    if (matches.length > 0) {
      for (Match match in matches) {
        // Group 1 should be the request
        // Group 2 should be the arguments

        String content_type = match.group(1);
       
        if (match.group(2).trim() != "") {
          AThingToAccept thing = new AcceptContentType(match.group(2));
        }

        if(!this.acceptContentTypes.containsKey(quality)) {
          AcceptSubCollection sub = new AcceptSubCollection();
          this.acceptContentTypes[quality] = sub;
           
        }
        
        this._log.info("Accept quality ${quality}: ${content_type}");
      }
    }

  }
}

class AcceptSubCollection {
  List<String> fullyQualified = new List<String>();
  List<String> partlyQualified = new List<String>();
  List<String> notQualified = new List<String>();

}
