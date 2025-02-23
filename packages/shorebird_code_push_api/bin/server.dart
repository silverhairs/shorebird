import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shorebird_code_push_api/src/middleware/middleware.dart';
import 'package:shorebird_code_push_api/src/routes/routes.dart';

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final router = shelf_router.Router()
    ..all('/', (_) => Response(HttpStatus.noContent))
    ..post('/api/v1/updates', checkForUpdatesHandler)
    ..get('/api/v1/releases/<version>', downloadReleaseHandler)
    ..post('/api/v1/releases', uploadReleaseHandler);

  final handler = const Pipeline()
      .addMiddleware(versionStoreProvider)
      .addHandler(router.call);

  final server = await shelf_io.serve(
    logRequests().addHandler(handler),
    InternetAddress.anyIPv4,
    port,
  );

  // ignore: avoid_print
  print('Serving at http://${server.address.host}:${server.port}');
}
