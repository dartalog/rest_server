part of rest;


class AcceptContentType extends AThingToAccept<AcceptContentType> {
  final Logger _log = new Logger('AcceptContentType');

  ContentType contentType;
  
  AcceptContentType(String spec): super(ContentType.parse(spec)) {
    this.contentType = this._headerValue;
    
    
    if(this.contentType.subType == "*") {
      if(this.contentType.primaryType == "*") {
        this.qualification = AThingToAccept._NOT_QUALIFIED;
      } else {
        this.qualification = AThingToAccept._PARTIALLY_QUALIFIED;
      } 
    } else {
      this.qualification = AThingToAccept._FULLY_QUALIFIED;
    }
    
    this._log.info("Accept Content-Type quality ${quality}: ${value}");
  }

  @override
  int compareTo(AcceptContentType other) {
    if(other.quality < this.quality) {
      return -1;
    } else if(other.quality > this.quality) {
      return 1;
    }
    if(other.qualification < this.qualification) {
      return -1;
    } else if(other.qualification > this.qualification) {
      return 1;
    }

    return 0;
  }
}