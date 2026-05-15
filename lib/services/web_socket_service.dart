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

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<void> connect(String token, String captainId) async {
    if (_initialized) return;
    _initialized = true;
    _token = token;
    _captainId = captainId;
    await _init();
  }

  Future<void> disconnect() async {
    _initialized = false;
    final captainId = _captainId;
    _token = null;
    _captainId = null;
    try {
      await _pusher.unsubscribe(channelName: 'orders');
      if (captainId != null) {
        // delivery.$captainId يغطي أحداث الشيفت والمحفظة معاً
        await _pusher.unsubscribe(channelName: 'delivery.$captainId');
      }
      await _pusher.disconnect();
    } catch (_) {}
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<void> _init() async {
    try {
      await _pusher.init(
        apiKey: AppConstants.apiKey,
        cluster: AppConstants.cluster,

        onEvent: (dynamic event) {
          if (event is PusherEvent) {
            print(
              '🌐 Global: ${event.channelName} → ${event.eventName}: ${event.data}',
            );
            _handleEvent(event);
          }
        },

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

      // ─── Channel الأوردرات العام ──────────────────────────────────────────
      await _pusher.subscribe(
        channelName: 'orders',
        onEvent: (dynamic event) {
          if (event is PusherEvent) {
            print('📨 orders → ${event.eventName}: ${event.data}');
            _handleEvent(event);
          }
        },
      );

      // ─── Channel الشيفت والمحفظة — نفس الـ channel ──────────────────────
      // Backend يبرودكاست الاتنين على delivery.$captainId
      if (_captainId != null) {
        await _pusher.subscribe(
          channelName: 'delivery.$_captainId',
          onEvent: (dynamic event) {
            if (event is PusherEvent) {
              print(
                '📨 delivery.$_captainId → ${event.eventName}: ${event.data}',
              );
              _handleEvent(event);
            }
          },
        );
      }

      await _pusher.connect();
      print('✅ Pusher connecting...');
    } catch (e) {
      print('❌ Pusher Init Error: $e');
      _initialized = false;
    }
  }

  void _handleEvent(PusherEvent event) {
    print(
      '🎯 ALL events: channel=${event.channelName} event=${event.eventName} data=${event.data}',
    );
    try {
      final raw = _decode(event.data);

      switch (event.eventName) {
        // ─── أحداث الأوردرات ──────────────────────────────────────────────
        case 'App\\Events\\NewOrderEvent':
          final message = raw['order'] ?? raw;
          final orderId =
              message['id']?.toString() ?? message['order_id']?.toString();
          if (orderId != null) {
            _controller.add({'event': 'new_order', 'order_id': orderId});
          }
          break;

        case 'App\\Events\\OrderStatusUpdated':
          final message = raw['message'] ?? raw;
          final orderId = (message['order_id'] ?? message['id'])?.toString();
          final status = message['status']?.toString();
          final deliveryId = message['delivery_id']?.toString();
          if (orderId != null) {
            _controller.add({
              'event': 'order_updated',
              'order_id': orderId,
              'status': status,
              'delivery_id': deliveryId,
            });
          }
          break;

        case 'order.cancelled':
          final orderId = raw['order_id']?.toString();
          if (orderId != null) {
            _controller.add({'event': 'order_cancelled', 'order_id': orderId});
          }
          break;

        // ─── أحداث الشيفت ─────────────────────────────────────────────────
        case 'shift.updated':
          print('🔄 shift.updated received: $raw');
          final status = raw['status']?.toString();
          if (status == 'started') {
            _controller.add({'event': 'shift_activated'});
          } else if (status == 'ended') {
            _controller.add({'event': 'shift_deactivated'});
          }
          break;

        // ─── أحداث المحفظة ────────────────────────────────────────────────
        // broadcastAs() في Backend = 'wallet.updated'
        // البيانات: { user_id, balance, amount, type, direction }
        case 'wallet.updated':
          final balance = raw['balance'];
          final amount = raw['amount'];
          final type = raw['type'];
          final dir = raw['direction'];
          print(
            '💰 wallet.updated received — balance: $balance, amount: $amount, type: $type, direction: $dir',
          );
          _controller.add({
            'event': 'wallet_updated',
            'balance': balance?.toString(),
            'amount': amount?.toString(),
            'type': type?.toString(),
            'direction': dir?.toString(),
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
