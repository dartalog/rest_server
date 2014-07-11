/// Server-side library to automate the minutia of creating a REST API.
/// Uses event handlers and Futures.
/// .

library rest;

import 'dart:io';
import 'dart:convert' as convert;
import 'dart:async';
import 'dart:collection';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';
import 'package:mime/mime.dart' as mime;

part 'src/http/http_method.dart';
part 'src/http/access_headers.dart';

part 'src/_a_rest_content_type_negotiator.dart';

part 'src/accept/a_thing_to_accept.dart';
part 'src/accept/accept_content_type.dart';
part 'src/accept/accept_collection.dart';

part 'src/rest_request.dart';
part 'src/rest_response.dart';
part 'src/rest_range.dart';
part 'src/rest_exception.dart';
part 'src/rest_server.dart';
part 'src/rest_resource.dart';
part 'src/rest_static_file_resource.dart';

const String _GLOBAL_METHOD = "GLOBAL";

typedef Future RestResourceMethodHandler(RestRequest request);
typedef Future<List<ContentType>> ManualContentTypeProvider(RestRequest request);

bool _isNullOrEmpty(String value) {
  if(value==null || value.trim() == "") {
    return true;
  } else {
    return false;
  }
}