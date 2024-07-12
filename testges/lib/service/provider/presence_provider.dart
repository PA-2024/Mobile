import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class PresenceNotifier extends StateNotifier<WebSocketChannel?> {
  PresenceNotifier() : super(null);

  void connectWebSocket(String url) {
    state = WebSocketChannel.connect(Uri.parse(url));
  }

  void disconnectWebSocket() {
    state?.sink.close(status.goingAway);
    state = null;
  }

  void sendMessage(String message) {
    state?.sink.add(message);
  }

  Stream<dynamic> get messages => state?.stream ?? Stream.empty();
}

final presenceProvider = StateNotifierProvider<PresenceNotifier, WebSocketChannel?>((ref) {
  return PresenceNotifier();
});
