import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notifications/main.dart';
import 'package:push_notifications/page/notification_screen.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notification',
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(
      NotificationScreen.route,
      arguments: message,
    );
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
          handleMessage(message);
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initNotifications() async {
    try {
      // Solicita permissão para notificações
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Permissão concedida para notificações');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('Permissão negada para notificações');
      } else {
        print('Permissão de notificações não foi determinada');
      }

      // Obtém o token FCM
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print('Token: $fcmToken');
      } else {
        print('Erro ao obter token FCM');
      }

      // Listener para quando o token é atualizado
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('Token atualizado: $newToken');
        // Aqui você pode atualizar o token no seu backend, se necessário
      });

      initPushNotifications();
      initLocalNotifications();

      // Listener para mensagens em primeiro plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Mensagem recebida em primeiro plano');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Payload: ${message.data}');
      });
    } catch (e) {
      print('Erro ao inicializar notificações: $e');
    }
  }
}
