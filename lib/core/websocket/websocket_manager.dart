import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  WebSocketChannel? _channel;
  String? _url;
  Timer? _retryTimer;
  bool _closed = false;

  void Function()? onOpen;
  void Function(String)? onMessage;
  void Function(String)? onFailure;
  void Function()? onClosed;

  static const _retryDelay = Duration(seconds: 4);

  void connect(String url) {
    _url = url;
    _closed = false;
    _open();
  }

  void _open() {
    _retryTimer?.cancel();
    _channel?.sink.close(1000);
    _channel = null;
    if (_closed || _url == null) return;
    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_url!),
        pingInterval: const Duration(seconds: 20),
      );
      onOpen?.call();
      _channel!.stream.listen(
        (message) => onMessage?.call(message.toString()),
        onError: (error) {
          onFailure?.call(error.toString());
          _scheduleRetry();
        },
        onDone: () {
          onClosed?.call();
          _scheduleRetry();
        },
      );
    } catch (e) {
      onFailure?.call(e.toString());
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_closed) return;
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, _open);
  }

  void send(String message) {
    _channel?.sink.add(message);
  }

  void disconnect() {
    _closed = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    _channel?.sink.close(1000);
    _channel = null;
  }
}
