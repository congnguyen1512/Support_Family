import 'dart:async';

import 'package:family_guard/core/constants/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase may fail to initialize in development when config files are missing.
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  void Function()? _onOpenNotifications;
  Future<void> Function(String token)? _onFcmToken;

  Future<void> initialize({
    void Function()? onOpenNotifications,
    Future<void> Function(String token)? onFcmToken,
  }) async {
    if (_initialized) {
      return;
    }

    _onOpenNotifications = onOpenNotifications;
    _onFcmToken = onFcmToken;
    try {
      await Firebase.initializeApp();
    } catch (error) {
      debugPrint('Firebase initialize failed: $error');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Push permission: ${settings.authorizationStatus}');

    await _initLocalNotifications();
    await _setupForegroundHandler();
    await _setupTapHandlers();
    await _logFcmToken();

    _initialized = true;
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) => _openNotificationsScreen(),
    );

    const channel = AndroidNotificationChannel(
      'family_guard_high_importance',
      'Support Family Alerts',
      description: 'Kênh thông báo khẩn và cập nhật an toàn',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupForegroundHandler() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final data = message.data;
      final title =
          notification?.title ?? data['title']?.toString() ?? 'Thông báo';
      final body =
          notification?.body ??
          data['body']?.toString() ??
          'Bạn có thông báo mới từ Support Family';

      debugPrint(
        'Push foreground message: title="$title", body="$body", data=$data',
      );

      await _localNotificationsPlugin.show(
        message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'family_guard_high_importance',
            'Support Family Alerts',
            channelDescription: 'Kênh thông báo khẩn và cập nhật an toàn',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  Future<void> _setupTapHandlers() async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Push tapped from background: data=${message.data}');
      _openNotificationsScreen();
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Push opened from terminated app: data=${initialMessage.data}');
      _openNotificationsScreen();
    }
  }

  Future<void> _logFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token: $token');
    await _syncToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed: $newToken');
      await _syncToken(newToken);
    });
  }

  Future<void> syncCurrentTokenToServer() async {
    final token = await FirebaseMessaging.instance.getToken();
    await _syncToken(token);
  }

  Future<void> _syncToken(String? token) async {
    final normalizedToken = token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) {
      return;
    }

    if (_onFcmToken == null) {
      return;
    }

    try {
      await _onFcmToken!.call(normalizedToken);
      debugPrint('FCM token synced to backend');
    } catch (error) {
      debugPrint('FCM token sync failed: $error');
    }
  }

  void _openNotificationsScreen() {
    if (_onOpenNotifications != null) {
      _onOpenNotifications!.call();
    }
  }

  void openDefaultNotificationsRoute(NavigatorState navigatorState) {
    navigatorState.pushNamed(AppRoutes.notifications);
  }
}
