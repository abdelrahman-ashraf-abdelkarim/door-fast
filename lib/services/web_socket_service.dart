// lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:captain_app/core/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>> get stream => _controller!.stream;

  bool _isConnected = false;
  Timer? _reconnectTimer;
  String? _token;

  void connect(String token) {
    _token = token;
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    _initConnection();
  }

  void _initConnection() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('${AppConstants.wsUrl}?token=$_token'),
      );
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _controller!.add(data);
        },
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
      );
    } catch (_) {
      _onDisconnected();
    }
  }

  void _onDisconnected() {
    _isConnected = false;
    // إعادة الاتصال بعد 5 ثواني
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_token != null) _initConnection();
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _controller?.close();
    _isConnected = false;
    _token = null;
  }
}
