import 'dart:io' as IO;
import 'dart:async' show runZoned;
import 'package:http_server/http_server.dart' show VirtualDirectory;

var staticFiles;

void main() {
  var environment = IO.Platform.environment['ENV'];
  if(environment == null) environment = 'development';
  var webDir = environment == 'development' ? 'web' : 'build';
  var buildUri = IO.Platform.script.resolve(webDir);

  staticFiles = new VirtualDirectory(buildUri.toFilePath());
  if(environment == 'development') {
    staticFiles.jailRoot = false;
  }
  staticFiles.allowDirectoryListing = true;
  staticFiles.directoryHandler = (dir, request) {
    var indexUri = new Uri.file(dir.path).resolve('index.html');
    staticFiles.serveFile(new IO.File(indexUri.toFilePath()), request);
  };

  var portEnv = IO.Platform.environment['PORT'];
  var port = portEnv == null ? 3000 : int.parse(portEnv);

  runZoned(() {
    IO.HttpServer.bind('0.0.0.0', port).then((server) {
      server.listen(onRequest);
    });
  },
  onError: (e, stackTrace) => print('Oh noes! $e $stackTrace'));
}

void onRequest(IO.HttpRequest request) {
  if(IO.WebSocketTransformer.isUpgradeRequest(request)) {
    IO.WebSocketTransformer.upgrade(request).then((IO.WebSocket socket) {
      socket.close();
    });
  } else {
    staticFiles.serveRequest(request);
  }
}
