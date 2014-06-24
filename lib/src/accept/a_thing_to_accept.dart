part of rest;

abstract class AThingToAccept<T> implements Comparable<T> {
  
  
  final Logger _a_log = new Logger('AThingToAccept');
  
  static const int _FULLY_QUALIFIED = 10;
  static const int _PARTIALLY_QUALIFIED = 5;
  static const int _NOT_QUALIFIED = 1;
  int qualification = _FULLY_QUALIFIED;
  
  static const double _DEFAULT_QUALITY = 1.0;
  double quality = _DEFAULT_QUALITY;
  String value;
  
  HeaderValue _headerValue;
  
  AThingToAccept(this._headerValue) {
    if(this._headerValue.parameters.containsKey("q")) {
      this.quality = double.parse(this._headerValue.parameters["q"]);
    }
    this.value = this._headerValue.value;
    
//    List<String> args = spec.split(';');
//    for (int i = 0; i < args.length; i++) {
//      String arg = args[i];
//      if(i==0) {
//        this.value = arg;
//        continue;
//      }
//      
//      if (arg.trim() != "") {
//        List<String> pair = arg.split("=");
//        if (pair.length == 2) {
//          switch (pair[0]) {
//            case "q":
//              quality = double.parse(pair[1]);
//              break;
//            default:
//              this._a_log.info("Unrecognized accept argument: ${arg} ");
//              break;
//          }
//        } else {
//          this._a_log.info("Incomplete argument pair in accept header: ${arg} ");
//        }
//      }
//    }

  }
  
  int compareTo(T other);
  
  @override
  String toString() {
    return this._headerValue.toString();
  }
}