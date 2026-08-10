import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wear_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WearProvider())],
      child: const IndieHubWearableApp(),
    ),
  );
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
        scaffoldBackgroundColor:
            Colors.black, // Optimizado para pantallas de relojes
      ),
      home: const WearableScreen(),
    );
  }
}

class WearableScreen extends StatelessWidget {
  const WearableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wearProvider = Provider.of<WearProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'IndieHub',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Mostrar datos localmente en tiempo real (SA.1.A)[cite: 2]
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.gamepad, size: 16, color: Colors.white54),
                    const SizedBox(width: 5),
                    Text(
                      '${wearProvider.playtimeHours} hrs jugadas',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.forum, size: 16, color: Colors.blueAccent),
                    const SizedBox(width: 5),
                    Text(
                      '${wearProvider.unreadMessages} msjs nuevos',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Alerta visual si hay petición 2FA[cite: 4]
                if (wearProvider.loginRequestPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '2FA REQUERIDO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Botón Iniciar/Detener (SA.1.A)[cite: 2]
                IconButton(
                  iconSize: 36,
                  color: wearProvider.isGenerating
                      ? Colors.redAccent
                      : Colors.greenAccent,
                  icon: Icon(
                    wearProvider.isGenerating
                        ? Icons.stop_circle
                        : Icons.play_circle_fill,
                  ),
                  onPressed: () => wearProvider.toggleDataGeneration(),
                ),
                Text(
                  wearProvider.isGenerating
                      ? 'Transmitiendo BLE'
                      : 'Transmisión Pausada',
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
