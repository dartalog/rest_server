part of rest;

abstract class ARestEventHandler {

  ARestEventHandler() {

  }

  Future Trigger(ContentType type, String path, Map<String, String> args);



}
