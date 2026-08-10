class BleConstants {
  // Servicio principal de IndieHub Wearable
  static const String indieHubServiceUUID =
      "000018FF-0000-1000-8000-00805f9b34fb";

  // Características GATT expuestas con NOTIFY (SA.1.A)
  static const String profileStatsUUID =
      "00002A01-0000-1000-8000-00805f9b34fb"; // Horas jugadas / Logros
  static const String communityAlertsUUID =
      "00002A02-0000-1000-8000-00805f9b34fb"; // Mensajes / Wishlist
  static const String security2FAUUID =
      "00002A03-0000-1000-8000-00805f9b34fb"; // Peticiones de login
}
