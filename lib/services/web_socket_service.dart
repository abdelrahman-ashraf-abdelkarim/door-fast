// lib/services/web_socket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:captain_app/core/constants.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class WebSocketService {
  WebSocketService._internal();
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  static final PusherChannelsFlutter _pusher =
      PusherChannelsFlutter.getInstance();
  static bool _initialized = false;

  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  String? _token;
  String? _captainId;

  // ─── Public API ───────────────────────────────────────────────

  Future<void> connect(String token, String captainId) async {
    if (_initialized) return;
    _initialized = true;
    _token = token;
    _captainId = captainId;
    await _init();
  }

  Future<void> disconnect() async {
    _initialized = false;
    _token = null;
    _captainId = null;
    try {
      await _pusher.unsubscribe(channelName: 'orders');
      await _pusher.disconnect();
    } catch (_) {}
  }

  // ─── Internal ─────────────────────────────────────────────────

  Future<void> _init() async {
    try {
      await _pusher.init(
        apiKey: AppConstants.apiKey,
        cluster: AppConstants.cluster,

        onConnectionStateChange: (currentState, previousState) {
          print('🔌 Pusher: $previousState → $currentState');
          if (currentState == 'DISCONNECTED' && _token != null) {
            Future.delayed(const Duration(seconds: 5), () => _pusher.connect());
          }
        },

        onError: (message, code, error) {
          print('❌ Pusher Error: $message');
          _initialized = false;
          Future.delayed(const Duration(seconds: 5), () {
            if (_token != null) _init();
          });
        },
      );

      // ─── Channel الأوردرات العام ───────────────────────────
      await _pusher.subscribe(
        channelName: 'orders',
        onEvent: (dynamic event) {
          if (event is PusherEvent) {
            print('📨 orders → ${event.eventName}: ${event.data}');
            _handleEvent(event);
          }
        },
      );

      await _pusher.connect();
      print('✅ Pusher connecting...');
    } catch (e) {
      print('❌ Pusher Init Error: $e');
      _initialized = false;
    }
  }

  void _handleEvent(PusherEvent event) {
    try {
      final raw = _decode(event.data);

      switch (event.eventName) {
        case 'App\\Events\\NewOrderEvent':
          _controller.add({'event': 'new_order', 'order': raw['order'] ?? raw});
          break;

        case 'App\\Events\\OrderStatusUpdated':
          _controller.add({
            'event': 'order_updated',
            'order': raw['order'] ?? raw['message'] ?? raw,
          });
          break;
      }
    } catch (e) {
      print('❌ Parse Error: $e');
    }
  }

  Map<String, dynamic> _decode(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    return {};
  }
}
