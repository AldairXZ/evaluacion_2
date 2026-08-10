import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ActivityProvider with ChangeNotifier {
  int _unreadCommunityMessages = 0;
  int _wishlistDiscounts = 0;
  bool _pending2FALogin = false;

  String _connectionStatus = 'Desconectado';
  bool _isAlertTriggered = false;

  // Nuevas variables para la simulación de escaneo BLE
  bool _isScanning = false;
  List<String> _scannedDevices = [];

  Timer? _bleSimulationTimer;
  late IO.Socket _socket;

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
    _socket.onConnect((_) => debugPrint('🔌 Conectado al WS de IndieHub'));
  }

  // --- Lógica de Escaneo y Conexión Simulada ---
  void startScanning() {
    _isScanning = true;
    _scannedDevices = [];
    notifyListeners();

    // Simula 2 segundos de escaneo BLE buscando UUIDs
    Timer(const Duration(seconds: 2), () {
      _scannedDevices = [
        'IndieHub Watch X1',
        'Wear OS Emulator 5556',
        'Reloj de Stefano',
      ];
      _isScanning = false;
      notifyListeners();
    });
  }

  void connectToDevice(String deviceName) {
    _connectionStatus = 'Conectando a $deviceName...';
    _scannedDevices = []; // Limpiamos la lista al conectar
    notifyListeners();

    Timer(const Duration(seconds: 2), () {
      _connectionStatus = 'Conectado a $deviceName';
      notifyListeners();
      _startListeningNotifications();
    });
  }

  void disconnectWearable() {
    _bleSimulationTimer?.cancel();
    _connectionStatus = 'Desconectado';
    _isAlertTriggered = false;
    _unreadCommunityMessages = 0;
    _wishlistDiscounts = 0;
    notifyListeners();
  }

  // --- Lógica de Sincronización ---
  void _startListeningNotifications() {
    _bleSimulationTimer?.cancel();
    _bleSimulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      _unreadCommunityMessages = (now.second % 4);
      _wishlistDiscounts = (now.second % 3);
      _pending2FALogin = (now.second % 15 == 0);

      if (_pending2FALogin) {
        _isAlertTriggered = true;
        _socket.emit('wearable_alert', {
          'mensaje': 'Verificación 2FA requerida en el reloj',
          'tipo': 'seguridad',
        });
      } else {
        _isAlertTriggered = false;
      }
      notifyListeners();
    });
  }

  void realizarCompraRapida(String juego) {
    _socket.emit('phone_action', {
      'mensaje': '¡Has adquirido $juego desde tu Wishlist!',
    });
  }

  @override
  void dispose() {
    _bleSimulationTimer?.cancel();
    _socket.dispose();
    super.dispose();
  }
}
