/// Server-side library to automate the minutia of create a REST API.
/// Uses event handlers and Futures.
/// .

library rest;

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:logging/logging.dart';

part 'src/rest_request.dart';
part 'src/rest_exception.dart';
part 'src/rest_server.dart';
part 'src/_rest_content_types.dart';
part 'src/rest_resource.dart';

const HTTP_GET = "GET";
const HTTP_POST = "POST";
const HTTP_OPTIONS = "OPTIONS";


typedef Future RestResourceMethod(RestRequest request);