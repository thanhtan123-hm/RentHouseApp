import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class notification {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings IOSInitializationSettings =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: IOSInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    // Xử lý phản hồi khi người dùng tương tác với thông báo.
  }

  static Future<void> showInstantNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  static Future<void> scheduleDailyMorningNotification(
      String title, String body) async {
    // Xác định múi giờ để lên lịch chính xác
    tz.initializeTimeZones();

    // Lấy múi giờ của Việt Nam
    final String timeZoneName = 'Asia/Ho_Chi_Minh'; // Múi giờ của Việt Nam
    final location = tz.getLocation(timeZoneName);

    // Tạo thời gian vào lúc 13:54 mỗi ngày
    final tz.TZDateTime now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduleTime = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      7,
    );

    // Kiểm tra nếu thời gian lên lịch đã qua trong ngày hiện tại, thì lên lịch vào ngày mai
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }
    // In ra thông tin để kiểm tra
    print('Múi giờ: $timeZoneName');
    print('Giờ hiện tại: ${now.toLocal()}');
    print('Thời gian lên lịch: ${scheduleTime.toLocal()}');

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduleTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Lặp lại hàng ngày
    );
  }
}
