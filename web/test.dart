import 'dart:html' as HTML;

void main() {
  print("Hello from Dart.");
  var uri = Uri.parse(HTML.window.location.href);
  var serverURL = "ws://${uri.host}:${uri.port}";
  WebSocket socket = new HTML.WebSocket(serverURL);
  socket.onOpen.listen((Event event) {
    print("Connection!");
  });
  socket.onClose.listen((Event event) {
    print("Disconnected!");
  });
}
