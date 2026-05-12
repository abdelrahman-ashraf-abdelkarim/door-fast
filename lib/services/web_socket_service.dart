// lib/services/web_socket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:captain_app/core/constants.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class WebSocketService {
  // ✅ Singleton
  WebSocketService._internal();
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>> get stream => _controller!.stream;

  bool _isConnected = false;
  bool _isInitialized = false;
  String? _token;

  // ─── Public API ───────────────────────────────────────────────

  Future<void> connect(String token, [String? captainId]) async {
    if (_isInitialized && _isConnected) return;
    _token = token;
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    await _initConnection();
  }

  Future<void> disconnect() async {
    _isInitialized = false;
    _isConnected = false;
    await _pusher.unsubscribe(channelName: 'orders');
    await _pusher.disconnect();
    _controller?.close();
    _controller = null;
    _token = null;
  }

  bool get isConnected => _isConnected;

  // ─── Internal ─────────────────────────────────────────────────

  Future<void> _initConnection() async {
    if (_isInitialized) return;
      _isInitialized = true;

    try {
      await _pusher.init(
        apiKey: AppConstants.apiKey,
        cluster: AppConstants.cluster,

        onConnectionStateChange: (currentState, previousState) {
          _isConnected = currentState == 'CONNECTED';
        },

        onError: (message, code, error) {
          _isConnected = false;
          _isInitialized = false;
          _scheduleReconnect();
        },
      );

      await _pusher.subscribe(channelName: 'orders', onEvent: _onEvent);

      await _pusher.connect();
    } catch (_) {
      _isConnected = false;
      _isInitialized = false;
      _scheduleReconnect();
    }
  }

  void _onEvent(PusherEvent event) {
    if (event.eventName != 'App\\Events\\OrderStatusUpdated') return;

    try {
      final raw = jsonDecode(event.data ?? '{}') as Map<String, dynamic>;

      // السيرفر بيبعت جوه 'message':
      // { order_id, status, order_number, delivery_id }
      final payload = raw['message'] is Map
          ? raw['message'] as Map<String, dynamic>
          : raw;

      _controller?.add(payload); // ✅ نبعت الـ payload زي ما هو للـ cubit
    } catch (_) {
      // ignore
    }
  }

  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_token != null) _initConnection();
    });
  }
}
