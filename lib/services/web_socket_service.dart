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

  StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  String? _token;
  String? _captainId;

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<void> connect(String token, String captainId) async {
    if (_initialized) return;
    // [FIX-09] recreate StreamController if it was closed
    if (_controller.isClosed) {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
    }
    _initialized = true;
    _token = token;
    _captainId = captainId;
    await _init();
  }

  Future<void> disconnect() async {
    // [FIX-09] close StreamController and reset initialized flag
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

    if (!_controller.isClosed) {
      await _controller.close();
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<void> _init() async {
    try {
      await _pusher.init(
        apiKey: AppConstants.apiKey,
        cluster: AppConstants.cluster,

        onEvent: (dynamic event) {
          if (event is PusherEvent) {
            _handleEvent(event);
          }
        },

        onConnectionStateChange: (currentState, previousState) {
          if (currentState == 'DISCONNECTED' && _token != null) {
            Future.delayed(const Duration(seconds: 5), () => _pusher.connect());
          }
        },

        onError: (message, code, error) {
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
              _handleEvent(event);
            }
          },
        );
      }

      await _pusher.connect();
    } catch (e) {
      _initialized = false;
    }
  }

  void _handleEvent(PusherEvent event) {
    try {
      final raw = _decode(event.data);

      switch (event.eventName) {
        // ─── أحداث الأوردرات ──────────────────────────────────────────────
        case 'App\\Events\\NewOrderEvent':
          final message = raw['order'] ?? raw;
          final orderId =
              message['id']?.toString() ?? message['order_id']?.toString();
          if (orderId != null) {
            _addEvent({'event': 'new_order', 'order_id': orderId});
          }
          break;

        case 'App\\Events\\OrderStatusUpdated':
          final message = raw['message'] ?? raw;
          final orderId = (message['order_id'] ?? message['id'])?.toString();
          final status = message['status']?.toString();
          final deliveryId = message['delivery_id']?.toString();
          if (orderId != null) {
            _addEvent({
              'event': 'order_updated',
              'order_id': orderId,
              'status': status,
              'delivery_id': deliveryId,
            });
          }
          break;
        case 'reserve_new_order':
          final message = raw['order'] ?? raw;
          final orderId =
              message['id']?.toString() ?? message['order_id']?.toString();
          if (orderId != null) {
            _addEvent({'event': 'reserve_new_order', 'order_id': orderId});
          }
          break;

        case 'order.cancelled':
          final orderId = raw['order_id']?.toString();
          if (orderId != null) {
            _addEvent({'event': 'order_cancelled', 'order_id': orderId});
          }
          break;

        // ─── أحداث الشيفت ─────────────────────────────────────────────────
        case 'shift.updated':
          final status = raw['status']?.toString();
          if (status == 'started') {
            _addEvent({'event': 'shift_activated'});
          } else if (status == 'ended') {
            _addEvent({'event': 'shift_deactivated'});
          }
          break;

        case 'account.deactivated':
          _addEvent({'event': 'account_deactivated'});
          break;

        // ─── أحداث المحفظة ────────────────────────────────────────────────
        // broadcastAs() في Backend = 'wallet.updated'
        // البيانات: { user_id, balance, amount, type, direction }
        case 'wallet.updated':
          final balance = raw['balance'];
          final amount = raw['amount'];
          final type = raw['type'];
          final dir = raw['direction'];
          _addEvent({
            'event': 'wallet_updated',
            'balance': balance?.toString(),
            'amount': amount?.toString(),
            'type': type?.toString(),
            'direction': dir?.toString(),
          });
          break;
      }
    } catch (_) {}
  }

  void _addEvent(Map<String, dynamic> event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  Map<String, dynamic> _decode(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    return {};
  }
}
