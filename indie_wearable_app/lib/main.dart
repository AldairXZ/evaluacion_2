import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const IndieHubWearableApp());
}

class IndieHubWearableApp extends StatelessWidget {
  const IndieHubWearableApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndieHub Wear',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Color(0xFFFF0055)),
      ),
      home: const WearSimulatorScreen(),
    );
  }
}

class WearSimulatorScreen extends StatefulWidget {
  const WearSimulatorScreen({Key? key}) : super(key: key);

  @override
  State<WearSimulatorScreen> createState() => _WearSimulatorScreenState();
}

class _WearSimulatorScreenState extends State<WearSimulatorScreen> {
  late IO.Socket socket;
  Timer? _timer;
  bool _isGenerating = false;

  int _xpGained = 0;
  int _sessionTimeSecs = 0;
  int _newMessages = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _setupWebSockets();
  }

  void _setupWebSockets() {
    // Conexión directa al servidor puente (Node.js) usando la IP del emulador
    socket = IO.io('http://10.0.2.2:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      debugPrint('Wearable conectado al ecosistema IndieHub');
    });
  }

  void _toggleSimulation() {
    setState(() {
      _isGenerating = !_isGenerating;
    });

    if (_isGenerating) {
      // Generamos datos cada segundo y los enviamos al servidor
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _xpGained += _random.nextInt(15) + 5;
          _sessionTimeSecs += 1;
          if (_random.nextInt(100) > 90) _newMessages += 1;
        });
        _broadcastDataToEcosystem();
      });
    } else {
      _timer?.cancel();
    }
  }

  void _broadcastDataToEcosystem() {
    // Calculamos los minutos con un decimal, tal como lo requiere tu UI
    double sessionMinutes = double.parse(
      (_sessionTimeSecs / 60).toStringAsFixed(1),
    );

    // Emitimos los datos al servidor Node.js para que rebote al Teléfono
    socket.emit('wearable_enviar_datos', {
      'xp': _xpGained,
      'tiempo': sessionMinutes,
      'mensajes': _newMessages,
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'IndieHub',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFFF0055),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildDataRow(Icons.star, 'XP', '$_xpGained'),
              _buildDataRow(
                Icons.timer,
                'Tiempo',
                '${(_sessionTimeSecs / 60).toStringAsFixed(1)}m',
              ),
              _buildDataRow(Icons.forum, 'Msjs', '$_newMessages'),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isGenerating
                      ? Colors.red[900]
                      : const Color(0xFFFF0055),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: _toggleSimulation,
                child: Icon(
                  _isGenerating ? Icons.stop : Icons.play_arrow,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
