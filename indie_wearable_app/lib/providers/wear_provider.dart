import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WearProvider extends ChangeNotifier {
  // Los datos locales que se mostrarán en la pantalla del reloj
  int xp = 0;
  double tiempo = 0.0;
  int mensajes = 0;

  // Estado para controlar el botón de Play/Stop
  bool isRunning = false;

  late IO.Socket socket;
  Timer? _timer;

  WearProvider() {
    _initSocket();
  }

  void _initSocket() {
    // Conexión al servidor local de Node.js a través del emulador
    socket = IO.io('http://10.0.2.2:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      debugPrint('Reloj conectado exitosamente al ecosistema');
    });
  }

  // Lógica del botón Iniciar/Detener exigida en la evaluación
  void toggleSimulation() {
    if (isRunning) {
      stopSimulation();
    } else {
      startSimulation();
    }
  }

  void startSimulation() {
    isRunning = true;
    notifyListeners();

    // Generamos datos cada cierto tiempo (ej. cada 2 segundos)
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Incremento de estadísticas del jugador
      xp += 14;
      tiempo += 0.1;

      // Añadimos un mensaje nuevo cada cierto tiempo simulado
      if (xp % 42 == 0) {
        mensajes += 1;
      }

      // Redondeamos a 1 decimal para evitar errores visuales en Flutter
      tiempo = double.parse(tiempo.toStringAsFixed(1));

      // EMISIÓN: Enviamos los datos generados al Backend
      socket.emit('wearable_enviar_datos', {
        'xp': xp,
        'tiempo': tiempo,
        'mensajes': mensajes,
      });

      notifyListeners(); // Actualiza la pantalla del reloj
    });
  }

  void stopSimulation() {
    isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  // Al cerrar la app, limpiamos el temporizador y el socket
  @override
  void dispose() {
    _timer?.cancel();
    socket.dispose();
    super.dispose();
  }
}
