rest_dart
=========

A library for automating much of the minutia of creating a rest interface. 
This mostly means automatically sending the correct error messages when a 
request is invalid, and some automatic header handling, such as:

- Automatic 204 messages when a resource returns no data but is still succesful.
- Automatic 404 messages when a requested resource does not exist.
- Automatic 405 errors when a method is not valid for a resource.
- Automatic 406 errors when requested content type is not available, or is not a valid content type.
- Automatic 415 errors when a submitted content type is not supported, or is not a valid content type.
- Automatic handling of the OPTIONS method, and automatic Allow header generation.
- Automatic setting of content-length and contnt-type headers.
- Provides a custom x-processing-time header that automatically contains how long it took for the server to generate a response.

###TODO:

- The error handling outputs the errors as JSON. This needs to be more flexible, and overridable.
- Add support for variable URL prefixes. Currently assumes running right under the host name/ip.
- Change rest event handlers to be generic functions instead of classes.
- Sets VERY generous Access-Control-Allow-Origin and Access-Control-Allow-Methods to allow cross-domain testing (this will be chagned to be mroe secure in the future).
- Per-resource/method content typing.



###Usage!

    // Import the package
    import 'package:rest_dart/rest_dart.dart';

    // Create the server object.
    RestServer rest = new RestServer();

    // If you don't add a content type, the server will throw an error on the first request.
    rest.AddDefaultContentType(new ContentType("application", "json", charset: "utf-8"));

    // Create a REST resource, along with the regex for recognizing its path.
    RestResource resource = new RestResource(r'^/?$');

    // Create a method handler
    Future DeleteHandler(ContentType type, String path, Map<String, String> args) {
      return new Future.sync(() {
        return "test";
      });
    }

    // Add the method handler to the resource 
    resource.SetMethodHandler("DELETE", DeleteHandler);

    // Add the resource to the server,
    rest.AddResource(resource);

    // Start the server. This handles creating the HTTP server as well.
    rest.Start("127.0.0.1",8080);

    // Begin requesting from the server!
    
###Errors

So, if something goes wrong and you need to send an error message back to the user, just throw a RestException!

    RestException(this.Code, this.Message, [this.InnerException = null]);

This will cause the server to send back the HTTP code you specify, and be presented with your message. 
Make sure to throw it through a future, so that it can be caught by the higher-up logic:

    Future DeleteHandler(ContentType type, String path, Map<String, String> args) {
      return new Future.sync(() {
        throw new RestException(500,"I don't like you");
      });
    }
