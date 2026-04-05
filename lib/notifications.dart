import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'models.dart';

final _notif = fln.FlutterLocalNotificationsPlugin();

const _quotes = [
  'Маленький шаг сегодня — большой прогресс завтра.',
  'Продуктивность — это не случайность.',
  'Один выполненный дедлайн лучше десяти запланированных.',
  'Сфокусируйся, начни, сделай.',
];

Future<void> initNotifications() async {
  try {
    tzdata.initializeTimeZones();
    final tzId = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzId as String));
    
    final androidSettings = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    await _notif.initialize(
      fln.InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (payload) {},
    );
  } catch (e) {
   print('Ошибка инициализации уведомлений: $e');
  }
}

Future<void> scheduleMorningNotif(List<Task> tasks) async {
  await _notif.cancelAll();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final soon = tasks.where((t) =>
    !t.isDone && t.deadline != null &&
    !t.deadline!.isBefore(today) &&
    t.deadline!.isBefore(today.add(const Duration(days: 3)))).length;
  final quote = _quotes[now.millisecond % _quotes.length];
  final body = soon > 0
    ? 'На ближайшие 3 дня: $soon задач(и).\n$quote'
    : 'Сегодня задач нет, отдохните :)\n$quote';

  var t7 = tz.TZDateTime.now(tz.local)
    ..add(Duration.zero); // получаем копию
  t7 = tz.TZDateTime(tz.local, t7.year, t7.month, t7.day, 7);
  if (t7.isBefore(tz.TZDateTime.now(tz.local))) t7 = t7.add(const Duration(days: 1));

  await _notif.zonedSchedule(
    0, '☀️ Доброе утро!', body, t7,
    const fln.NotificationDetails(android: fln.AndroidNotificationDetails(
      'morning_ch', 'Утреннее напоминание',
      importance: fln.Importance.max, priority: fln.Priority.high,
      ongoing: true, autoCancel: false)),
    uiLocalNotificationDateInterpretation:
      fln.UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: fln.DateTimeComponents.time,
    androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle);
}
