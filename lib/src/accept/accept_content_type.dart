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
    // Higher quality items are always sorted first
    if(other.quality < this.quality) {
      return -1;
    } else if(other.quality > this.quality) {
      return 1;
    }
    
    // Within quality, whether the item is fully, partially, or not qualified
    if(other.qualification < this.qualification) {
      return -1;
    } else if(other.qualification > this.qualification) {
      return 1;
    }
    
    // Within qualification, if a charset is specified that makes it more specific, and thus sorted first
    if(_isNullOrEmpty(other.contentType.charset)) {
      if(!_isNullOrEmpty(this.contentType.charset)) {
        return 1;
      }
    } else {
      if(_isNullOrEmpty(this.contentType.charset)) {
        return -1;
      }
    }

    return 0;
  }
  
  bool matches(ContentType type) {
    if(type.subType == this.contentType.subType || this.contentType.subType == "*") {
      if(type.primaryType == this.contentType.primaryType || this.contentType.primaryType == "*") {
        if(type.charset == this.contentType.charset || _isNullOrEmpty(this.contentType.charset)) {
          return true;
        }
      }
    }
    return false;
  }
}