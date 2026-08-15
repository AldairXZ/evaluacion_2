import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ActivityProvider with ChangeNotifier {
  int _playtimeHours = 0;
  int _achievements = 0;
  int _unreadCommunityMessages = 0;
  int _wishlistDiscounts = 0;

  bool _pending2FALogin = false;
  String _connectionStatus = 'Desconectado';
  bool _isAlertTriggered = false;

  bool _isScanning = false;
  List<String> _scannedDevices = [];

  late IO.Socket _socket;

  int get playtimeHours => _playtimeHours;
  int get achievements => _achievements;
  int get unreadCommunityMessages => _unreadCommunityMessages;
  int get wishlistDiscounts => _wishlistDiscounts;
  bool get pending2FALogin => _pending2FALogin;
  String get connectionStatus => _connectionStatus;
  bool get isAlertTriggered => _isAlertTriggered;
  bool get isScanning => _isScanning;
  List<String> get scannedDevices => _scannedDevices;

  ActivityProvider() {
    _initWebSocket();
  }

  void _initWebSocket() {
    _socket = IO.io(
      'http://10.0.2.2:3001',
      IO.OptionBuilder().setTransports(['websocket']).setAuth({
        'token': 'indiehub-phone-client-token',
      }).build(),
    );

    _socket.on('sync_wearable_data', (data) {
      if (!_connectionStatus.contains('Conectado')) return;
      _playtimeHours = data['horas'];
      _achievements = data['logros'];
      _unreadCommunityMessages = data['mensajes'];
      _wishlistDiscounts = data['descuentos'];
      notifyListeners();
    });

    _socket.on('2fa_request', (data) {
      if (!_connectionStatus.contains('Conectado')) return;
      _isAlertTriggered = true;
      notifyListeners();
    });

    _socket.on('2fa_approved_success', (data) {
      _isAlertTriggered = false;
      notifyListeners();
    });
  }

  void approve2FA() {
    _socket.emit('2fa_approved', {});
  }

  void startScanning() {
    _isScanning = true;
    _scannedDevices = [];
    notifyListeners();

    Timer(const Duration(seconds: 2), () {
      _scannedDevices = ['IndieHub Watch X1', 'Wear OS Emulator 5556'];
      _isScanning = false;
      notifyListeners();
    });
  }

  void connectToDevice(String deviceName) {
    _connectionStatus = 'Conectando a $deviceName...';
    _scannedDevices = [];
    notifyListeners();

    Timer(const Duration(seconds: 2), () {
      _connectionStatus = 'Conectado a $deviceName';
      notifyListeners();
    });
  }

  void disconnectWearable() {
    _connectionStatus = 'Desconectado';
    _isAlertTriggered = false;
    _playtimeHours = 0;
    _achievements = 0;
    _unreadCommunityMessages = 0;
    _wishlistDiscounts = 0;
    _pending2FALogin = false;
    notifyListeners();
  }

  void realizarCompraRapida(Map<String, dynamic> juego) {
    _socket.emit('phone_purchase', juego);
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}
