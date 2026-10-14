import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Manejar interacción del usuario al tocar la notificación
      },
    );
  }

  /// Programa una notificación para cuando el contador de riego llegue a cero
  Future<void> schedulePlantWatering({
    required String plantId,
    required String plantName,
    required DateTime scheduledDate,
  }) async {
    final id = plantId.hashCode;

    // Horario habitual: 9:00 AM del día programado
    final targetDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9,
      0,
    );

    if (targetDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      '💧 ¡Hora de regar tu $plantName!',
      'Tu planta necesita agua hoy para mantener su vigor botánico.',
      tz.TZDateTime.from(targetDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mis_plantas_watering_channel',
          'Recordatorios de Riego',
          channelDescription: 'Alertas cuando las plantas requieren hidratación',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelForPlant(String plantId) async {
    await _notificationsPlugin.cancel(plantId.hashCode);
  }
}
