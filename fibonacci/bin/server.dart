import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future main() async {
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');

  Future<Response> handler(Request request) => fibonacci(request);

  var server = await serve(
    Pipeline().addMiddleware(logRequests()).addHandler(handler),
    InternetAddress.anyIPv4,
    port!,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> fibonacci(Request request) async {
  var data = await decodeRequest(request);
  if(!data.containsKey('value')) return createResponse(-1);
  if(!data.containsKey('url')) return createResponse(-1);

  var value = data['value'];
  if(value == 0) return createResponse(0);
  if(value == 1 || value == 2) return createResponse(1);

  var v1 = jsonEncode({'url': data['url'], 'value':value - 1});
  var v2 = jsonEncode({'url': data['url'], 'value':value - 2});
  var rtn1 = await decodeResponse(http.post(Uri.parse(data['url']), body: v1));
  var rtn2 = await decodeResponse(http.post(Uri.parse(data['url']), body: v2));

  var result = rtn1 + rtn2;
  return createResponse(result);
}

Response createResponse(int result) {
  final headers = {'content-type': 'application/json; charset=utf-8'};
  return Response.ok(json.encode({'value': result}), headers: headers);
}

Future<Map<String, dynamic>> decodeRequest(Request request) async {
  final body = await request.readAsString();
  final Map<String, dynamic> data = json.decode(body);
  return data;
}

Future<int> decodeResponse(Future<http.Response> response) async {
  final body = await response;
  var data = json.decode(body.body);
  return data['value'];
}
