import 'dart:io' show File, HttpServer, Platform;
import 'dart:async' show runZoned;
import 'package:http_server/http_server.dart' show VirtualDirectory;

void main() {
  var environment = Platform.environment['ENV'];
  if(environment == null) environment = 'development';
  var webDir = environment == 'development' ? 'web' : 'build';
  var buildUri = Platform.script.resolve(webDir);

  var staticFiles = new VirtualDirectory(buildUri.toFilePath());
  if(environment == 'development') {
    staticFiles.jailRoot = false;
  }

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);

  runZoned(() {
    HttpServer.bind('0.0.0.0', port).then((server) {
      server.listen(staticFiles.serveRequest);
    });
  },
  onError: (e, stackTrace) => print('Oh noes! $e $stackTrace'));
}
