import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WearProvider with ChangeNotifier {
  bool _isGenerating = false;
  Timer? _sensorTimer;
  late IO.Socket _socket;

  int _playtimeHours = 130;
  int _achievements = 45;
  int _unreadMessages = 0;
  int _wishlistDiscounts = 0;

  bool _loginRequestPending = false;
  String _juegoPendiente = "";

  bool get isGenerating => _isGenerating;
  int get playtimeHours => _playtimeHours;
  int get achievements => _achievements;
  int get unreadMessages => _unreadMessages;
  int get wishlistDiscounts => _wishlistDiscounts;
  bool get loginRequestPending => _loginRequestPending;
  String get juegoPendiente => _juegoPendiente;

  WearProvider() {
    _initWebSocket();
  }

  void _initWebSocket() {
    _socket = IO.io(
      'http://10.0.2.2:3001',
      IO.OptionBuilder().setTransports(['websocket']).setAuth({
        'token': 'indiehub-wearable-token',
      }).build(),
    );

    _socket.onConnect((_) {});

    _socket.on('2fa_request', (data) {
      _loginRequestPending = true;
      _juegoPendiente = data['mensaje'];
      notifyListeners();
    });

    _socket.on('2fa_approved_success', (data) {
      _loginRequestPending = false;
      _juegoPendiente = "";
      notifyListeners();
    });
  }

  void approve2FA() {
    _socket.emit('2fa_approved', {});
  }

  void toggleDataGeneration() {
    _isGenerating = !_isGenerating;
    if (_isGenerating) {
      _startSensors();
    } else {
      _stopSensors();
    }
    notifyListeners();
  }

  void _startSensors() {
    _sensorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      _playtimeHours = 130 + (now.minute % 10);
      _achievements = 45 + (now.minute % 5);
      _unreadMessages = (now.second % 4);
      _wishlistDiscounts = (now.second % 3);

      _socket.emit('sync_wearable_data', {
        'horas': _playtimeHours,
        'logros': _achievements,
        'mensajes': _unreadMessages,
        'descuentos': _wishlistDiscounts,
      });

      notifyListeners();
    });
  }

  void _stopSensors() {
    _sensorTimer?.cancel();
  }

  @override
  void dispose() {
    _stopSensors();
    _socket.dispose();
    super.dispose();
  }
}
