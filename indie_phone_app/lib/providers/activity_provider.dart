import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ActivityProvider extends ChangeNotifier {
  String connectionState = 'desconectado';
  int xpGained = 0;
  double sessionTime = 0.0;
  int newMessages = 0;

  late IO.Socket socket;

  ActivityProvider() {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io('http://10.0.2.2:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // ESCUCHAR AL RELOJ A TRAVÉS DEL SERVIDOR (Simulando recepción BLE)
    socket.on('telefono_recibir_datos_ble', (data) {
      if (connectionState == 'conectado') {
        // Actualizamos la UI exactamente con los datos que manda el reloj
        xpGained = data['xp'] ?? 0;
        sessionTime = (data['tiempo'] ?? 0.0).toDouble();
        newMessages = data['mensajes'] ?? 0;

        // Disparar alerta hacia la TV si el tiempo de sesión es muy alto
        if (sessionTime >= 1.0) {
          socket.emit('wearable_ritmo_cardiaco', {'bpm': 105});
        }

        notifyListeners();
      }
    });
  }

  Future<void> scanAndConnect() async {
    connectionState = 'buscando';
    notifyListeners();

    // Solo simulamos el retraso de conexión de 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    connectionState = 'conectado';
    // Ya no inyectamos datos aquí, esperamos a que el socket los reciba
    notifyListeners();
  }

  void buyGame(String id, String title) {
    socket.emit('telefono_compra_juego', {'juegoId': id, 'titulo': title});
  }

  void disconnect() {
    connectionState = 'desconectado';
    xpGained = 0;
    sessionTime = 0.0;
    newMessages = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
