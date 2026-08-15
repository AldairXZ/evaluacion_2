import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/activity_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ActivityProvider())],
      child: const IndieHubPhoneApp(),
    ),
  );
}

class IndieHubPhoneApp extends StatelessWidget {
  const IndieHubPhoneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndieHub Phone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1722),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFBBF24),
          secondary: Colors.blueAccent,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StoreTab(),
    const CommunitySecurityTab(),
    const PairingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IndieHub Mobile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black45,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFFFBBF24),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Tienda'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Comunidad'),
          BottomNavigationBarItem(icon: Icon(Icons.watch), label: 'Vincular'),
        ],
      ),
    );
  }
}

class StoreTab extends StatelessWidget {
  const StoreTab({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _juegosDiferentes = const [
    {
      "title": "Cuphead",
      "developer": "Studio MDHR",
      "price": "19.99",
      "bg":
          "https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=800&q=80",
    },
    {
      "title": "Dead Cells",
      "developer": "Motion Twin",
      "price": "24.99",
      "bg":
          "https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=800&q=80",
    },
    {
      "title": "Ori and the Blind Forest",
      "developer": "Moon Studios",
      "price": "19.99",
      "bg":
          "https://images.unsplash.com/photo-1552820728-8b83bb6b773f?auto=format&fit=crop&w=800&q=80",
    },
    {
      "title": "Slay the Spire",
      "developer": "Mega Crit Games",
      "price": "24.99",
      "bg":
          "https://images.unsplash.com/photo-1534423861386-85a16f5d13fd?auto=format&fit=crop&w=800&q=80",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu Wishlist',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _juegosDiferentes.length,
              itemBuilder: (context, index) {
                final juego = _juegosDiferentes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.videogame_asset,
                          size: 30,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              juego['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${juego['price']}',
                              style: const TextStyle(color: Colors.greenAccent),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => provider.realizarCompraRapida(juego),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBBF24),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Comprar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CommunitySecurityTab extends StatelessWidget {
  const CommunitySecurityTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (provider.isAlertTriggered)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security, color: Colors.amber, size: 30),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Intento de inicio de sesión detectado en Smart TV',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => provider.approve2FA(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Aprobar'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Denegar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const Text(
            'Sincronización IndieHub',
            style: TextStyle(fontSize: 18, color: Colors.white54),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildMetricCard(
                  'Horas Jugadas',
                  '${provider.playtimeHours}h',
                  Icons.gamepad,
                  Colors.blueAccent,
                ),
                _buildMetricCard(
                  'Logros',
                  '${provider.achievements}',
                  Icons.emoji_events,
                  Colors.amber,
                ),
                _buildMetricCard(
                  'Foro',
                  '${provider.unreadCommunityMessages} msjs',
                  Icons.forum,
                  Colors.greenAccent,
                ),
                _buildMetricCard(
                  'Ofertas',
                  '${provider.wishlistDiscounts} items',
                  Icons.local_offer,
                  Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PairingTab extends StatelessWidget {
  const PairingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  provider.connectionStatus.contains('Conectado')
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: provider.connectionStatus.contains('Conectado')
                      ? Colors.greenAccent
                      : Colors.grey,
                ),
                const SizedBox(width: 15),
                Text(
                  provider.connectionStatus,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (!provider.connectionStatus.contains('Conectado'))
            ElevatedButton.icon(
              onPressed: provider.isScanning
                  ? null
                  : () => provider.startScanning(),
              icon: provider.isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(
                provider.isScanning
                    ? 'Escaneando...'
                    : 'Buscar Relojes Cercanos',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),

          if (provider.connectionStatus.contains('Conectado'))
            OutlinedButton.icon(
              onPressed: () => provider.disconnectWearable(),
              icon: const Icon(Icons.link_off, color: Colors.redAccent),
              label: const Text(
                'Desvincular Dispositivo',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Colors.redAccent),
              ),
            ),

          const SizedBox(height: 20),

          if (provider.scannedDevices.isNotEmpty) ...[
            const Text(
              'Dispositivos Encontrados:',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: provider.scannedDevices.length,
                itemBuilder: (context, index) {
                  final deviceName = provider.scannedDevices[index];
                  return Card(
                    color: const Color(0xFF1E293B),
                    child: ListTile(
                      leading: const Icon(Icons.watch),
                      title: Text(deviceName),
                      trailing: const Text(
                        'Conectar',
                        style: TextStyle(color: Color(0xFFFBBF24)),
                      ),
                      onTap: () => provider.connectToDevice(deviceName),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
