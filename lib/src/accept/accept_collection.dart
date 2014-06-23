part of rest;

class AcceptCollection {
  final Logger _log = new Logger('AcceptCollection');

  Map<double, AcceptSubCollection> acceptContentTypes = new Map<double, AcceptSubCollection>();

  String source;

  static String _ACCEPT_HEADER_REGEX = "([^,;]+)((;[^;^,]+)*)";
  static RegExp _acceptHeaderRegexp = new RegExp(_ACCEPT_HEADER_REGEX);

  AcceptCollection(String accept_header) {
    Iterable<Match> matches = _acceptHeaderRegexp.allMatches(accept_header);
    if (matches.length > 0) {
      for (Match match in matches) {
        // Group 1 should be the request
        // Group 2 should be the arguments

        String content_type = match.group(1);
        double quality = 1.0;
        if (match.group(2).trim() != "") {
          List<String> args = match.group(2).split(';');
          for (String arg in args) {
            if (arg.trim() != "") {
              List<String> pair = arg.split("=");
              if (pair.length == 2) {
                switch (pair[0]) {
                  case "q":
                    quality = double.parse(pair[1]);
                    break;
                  default:
                    this._log.info("Unrecognized accept argument: ${arg} ");
                    break;
                }
              } else {
                this._log.info("Incomplete argument pair in accept header: ${arg} ");
              }
            }
          }
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
