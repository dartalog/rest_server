part of rest;

abstract class AThingToAccept {
  final Logger _log = new Logger('AThingToAccept');
  
  static const double _DEFAULT_QUALITY = 1.0;
  double quality = _DEFAULT_QUALITY;
  
  AThingToAccept(String spec) {
    List<String> args = spec.split(';');
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
}