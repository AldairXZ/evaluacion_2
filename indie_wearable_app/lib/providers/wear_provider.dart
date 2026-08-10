import 'dart:async';
import 'package:flutter/foundation.dart';
import '../ble_constants.dart';

class WearProvider with ChangeNotifier {
  bool _isGenerating = false;
  Timer? _sensorTimer;

  // 3 tipos de datos generados según el caso de estudio (SA.1.A)[cite: 2, 4]
  int _playtimeHours = 130;
  int _unreadMessages = 0;
  bool _loginRequestPending = false;

  bool get isGenerating => _isGenerating;
  int get playtimeHours => _playtimeHours;
  int get unreadMessages => _unreadMessages;
  bool get loginRequestPending => _loginRequestPending;

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
    // Genera datos relevantes del ecosistema cada segundo (SA.1.A)[cite: 2]
    _sensorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      // Fórmulas matemáticas idénticas al Teléfono para asegurar sincronización
      _playtimeHours = 130 + (now.minute % 10);
      _unreadMessages = (now.second % 4);
      int mockDiscounts = (now.second % 3);

      // Simula una petición 2FA aleatoria en sincronía[cite: 4]
      _loginRequestPending = (now.second % 15 == 0);

      _notifyGattCharacteristics(mockDiscounts);
      notifyListeners();
    });
  }

  void _stopSensors() {
    _sensorTimer?.cancel();
  }

  // Simulación de exposición GATT con NOTIFY para cada tipo de dato (SA.1.A)[cite: 2]
  void _notifyGattCharacteristics(int mockDiscounts) {
    debugPrint(
      "NOTIFY [Perfil]: $_playtimeHours hrs -> UUID: ${BleConstants.profileStatsUUID}",
    );
    debugPrint(
      "NOTIFY [Comunidad]: $_unreadMessages msjs, $mockDiscounts desc -> UUID: ${BleConstants.communityAlertsUUID}",
    );
    debugPrint(
      "NOTIFY [Seguridad 2FA]: $_loginRequestPending -> UUID: ${BleConstants.security2FAUUID}",
    );
  }

  @override
  void dispose() {
    _stopSensors();
    super.dispose();
  }
}
