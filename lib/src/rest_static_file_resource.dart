part of rest;

class RestStaticFileResource extends RestResource {
  final Logger _rsf_log = new Logger('RestStaticFileResource');
  
  String _path;
  
  RestStaticFileResource(String regex, this._path): super(regex) {
    this.ignoreGlobalContentTypes = true;
    setMethodHandler("GET", _getMethod);
    this.manualAvailableContentTypes = _manualAvailableContentTypes;
  }
  
  Future<List<ContentType>> _manualAvailableContentTypes(RestRequest request) {
    List<ContentType> output = new List<ContentType>();
    return new Future.sync(() {
      File file = _findFile(request);
      ContentType type = _getFileContentType(file);
      output.add(type);
      return output;
    });
  }
  
  File _findFile(RestRequest request) {
    Match match = this._regex.firstMatch(request.httpRequest.uri.path);
    if(match.groupCount == 0) {
      throw new RestException(HttpStatus.INTERNAL_SERVER_ERROR,"RestStaticFileResource regex does not contain a group");
    }

    
    String file_path;
    if(_isNullOrEmpty(this._path)||!path.isAbsolute(this._path)) {
      file_path = Directory.current.path;
    }
        
    if(!_isNullOrEmpty(this._path)) {
      file_path = path.join(file_path,this._path);
    }
    
    file_path = path.join(file_path,adjustFilePath(match.group(1)));
    
    File file = new File(file_path);
    
    if(!file.existsSync()) {
      throw new RestException(HttpStatus.NOT_FOUND,"The requested resource was not found");
    }

    return file;
  }
  
  String adjustFilePath(String filename) {
    return filename;
  }
  
  ContentType _getFileContentType(File file) {
    RandomAccessFile ra_file = file.openSync(mode: FileMode.READ);
    List<int> buffer = new List<int>(mime.defaultMagicNumbersMaxLength);
    ra_file.readIntoSync(buffer,0,mime.defaultMagicNumbersMaxLength);
    ra_file.closeSync();
    String str_mime = mime.lookupMimeType(file.path, headerBytes: buffer);
    if(str_mime==null) {
      str_mime = "text/plain";
    }
    this._rsf_log.info("Determined file '${file.path}' is of mimetype '${str_mime}");
    return ContentType.parse(str_mime);
  }
  
  Future _getMethod(RestRequest request) {
    return new Future.sync(() {
      File file = this._findFile(request);
      return file.readAsBytes();
    });
  }


}