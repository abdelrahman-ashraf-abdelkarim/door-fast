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

  // ─── State ────────────────────────────────────────────────────────────────
  bool _initialized = false;
  bool _isConnected = false; // ✅ تتبع حالة الاتصال الفعلية

  // ─── Exponential Backoff ──────────────────────────────────────────────────
  int _retryCount = 0;
  Timer? _retryTimer;

  Duration get _retryDelay {
    final seconds = (5 * (1 << _retryCount)).clamp(5, 60);
    return Duration(seconds: seconds);
  }
  // ─────────────────────────────────────────────────────────────────────────

  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  String? _token;
  String? _captainId;

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<void> connect(String token, String captainId) async {
    if (_initialized) return;
    _initialized = true;
    _isConnected = false;
    _token = token;
    _captainId = captainId;
    _retryCount = 0;
    await _init();
  }

  Future<void> disconnect() async {
    _initialized = false;
    _isConnected = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryCount = 0;
    final captainId = _captainId;
    _token = null;
    _captainId = null;
    try {
      await _pusher.unsubscribe(channelName: 'orders');
      if (captainId != null) {
        await _pusher.unsubscribe(channelName: 'delivery.$captainId');
      }
      await _pusher.disconnect();
    } catch (_) {}
  }

  // ✅ reconnect — يُستدعى من HomeShell عند رجوع الـ app من الـ background
  // الفرق عن الإصدار القديم: بيشتغل حتى لو _initialized = true
  // لأن الاتصال ممكن يكون اتقطع من غير ما _initialized يتغير
  Future<void> reconnect() async {
    if (_token == null || _captainId == null) return;

    // ✅ لو الاتصال شغّال فعلاً، مش محتاج نعمل حاجة
    if (_isConnected) return;

    // ✅ reset كامل وابدأ من أول
    _initialized = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryCount = 0;
    _initialized = true;
    await _init();
  }
  // ─────────────────────────────────────────────────────────────────────────

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
          if (currentState == 'CONNECTED') {
            _isConnected = true; // ✅ سجّل أن الاتصال شغّال
            _retryCount = 0;
            _retryTimer?.cancel();
            _retryTimer = null;
          }

          if (currentState == 'DISCONNECTED') {
            _isConnected = false; // ✅ سجّل أن الاتصال انقطع
            if (_token != null) {
              _scheduleRetryConnect();
            }
          }
        },

        onError: (message, code, error) {
          _isConnected = false;
          _initialized = false;
          if (_token != null) {
            _scheduleRetryInit();
          }
        },
      );

      await _pusher.subscribe(
        channelName: 'orders',
        onEvent: (dynamic event) {
          if (event is PusherEvent) {
            _handleEvent(event);
          }
        },
      );

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
      _isConnected = false;
      _initialized = false;
      if (_token != null) {
        _scheduleRetryInit();
      }
    }
  }

  // ✅ retry للـ connect فقط (الـ pusher اتقطع لكن init تم)
  void _scheduleRetryConnect() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      _retryCount++;
      if (_token != null) _pusher.connect();
    });
  }

  // ✅ retry كامل من الـ _init (حصل error في الـ init نفسه)
  void _scheduleRetryInit() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      _retryCount++;
      if (_token != null) {
        _initialized = true;
        _init();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────

  void _handleEvent(PusherEvent event) {
    try {
      final raw = _decode(event.data);

      switch (event.eventName) {
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
