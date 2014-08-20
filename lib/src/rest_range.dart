part of rest;
/**
 * An object to manage range requests via the [HttpHeaders.ACCEPT_RANGE] header 
 * and responses via the [HttpHeaders.CONTENT_RANGE] header.
 */
class RestRange {
  static const String _RANGE_REGEXP_STRING = r"([^=]+)=(\d+)-(\d+)";
  static final RegExp _RANGE_REGEXP = new RegExp(_RANGE_REGEXP_STRING);
  static final Logger _log = new Logger('RestRange');
  
  /// The name of the range type, for example "files" or 'bytes".
  String name;
  /// The start position of the range.
  int start;
  /// The end position of the range.
  int end;
  /// The total units available, sent out automatically as part of [HttpHeaders.CONTENT_RANGE].
  int total;

  /// The total units contained within the range.
  int get count  {
    return end - start + 1;
    
  }

  RestRange._fromValues(this.name, this.start, this.end, this.total) {
    if(_isNullOrEmpty(name)) {
      throw new Exception("Name of range is required");
    }
    if(end < start) {
      throw new Exception("Range's start is greater than the end");
    }
    if(end > total) {
      throw new Exception("Range's end is greater than the total");
    }
  }
  
  RestRange._fromRangeHeader(String range_header) {
    if(_RANGE_REGEXP.hasMatch(range_header)) {
      Match m = _RANGE_REGEXP.firstMatch(range_header);
      name = m.group(1);
      if(_isNullOrEmpty(name)) {
        throw new RestException(HttpStatus.BAD_REQUEST, "Name of range in the range header is required");
      }
      start = int.parse(m.group(2));
      end = int.parse(m.group(3));
      _log.info("Range Header - name: ${name} start: ${start} end: ${end}");
      if(end < start) {
        throw new RestException(HttpStatus.BAD_REQUEST, "Range header's start is greater than the end");
      }
      
    } else {
      throw new RestException(HttpStatus.BAD_REQUEST, "Format of Range header is invalid: ${range_header}");
    }
  }
  
  void _setResponseHeaders(HttpRequest req) {
    //req.response.headers.add(HttpHeaders.ACCEPT_RANGES, name);
    req.response.headers.add(HttpHeaders.CONTENT_RANGE, "${name} ${start}-${end}/${total}");
  }
}