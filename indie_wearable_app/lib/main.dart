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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Color(0xFFFBBF24)),
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
          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'IndieHub',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWearMetric(
                    Icons.gamepad,
                    '${wearProvider.playtimeHours}h',
                    Colors.blueAccent,
                  ),
                  _buildWearMetric(
                    Icons.emoji_events,
                    '${wearProvider.achievements}',
                    Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWearMetric(
                    Icons.forum,
                    '${wearProvider.unreadMessages}',
                    Colors.greenAccent,
                  ),
                  _buildWearMetric(
                    Icons.local_offer,
                    '${wearProvider.wishlistDiscounts}',
                    Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (wearProvider.loginRequestPending)
                Column(
                  children: [
                    Text(
                      wearProvider.juegoPendiente,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 0,
                        ),
                        minimumSize: const Size(80, 30),
                      ),
                      onPressed: () => wearProvider.approve2FA(),
                      child: const Text(
                        'APROBAR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              GestureDetector(
                onTap: wearProvider.toggleDataGeneration,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: wearProvider.isGenerating
                        ? Colors.redAccent.withOpacity(0.2)
                        : Colors.greenAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: wearProvider.isGenerating
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    wearProvider.isGenerating
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    color: wearProvider.isGenerating
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                wearProvider.isGenerating ? 'Transmitiendo' : 'Pausado',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWearMetric(IconData icon, String value, Color color) {
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
