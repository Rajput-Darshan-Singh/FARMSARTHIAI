import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> showDetectionResult(
      String diseaseName, double confidence) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'detection_channel',
      'Disease Detection Results',
      channelDescription: 'Notifications for disease detection results',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Disease Detected: $diseaseName',
      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
      details,
    );
  }

  Future<void> showExpertResponse(String expertName, String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'expert_channel',
      'Expert Responses',
      channelDescription: 'Notifications for expert responses',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1,
      'Response from $expertName',
      message,
      details,
    );
  }

  Future<void> scheduleDailyTips() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'tips_channel',
      'Daily Farming Tips',
      channelDescription: 'Daily tips and advice for farmers',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.periodicallyShow(
      2,
      'Daily Farming Tip',
      'Check your crops regularly for early signs of disease',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
