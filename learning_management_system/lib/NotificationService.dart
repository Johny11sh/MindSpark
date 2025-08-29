import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();


  static Future<void> init() async {
    await _initFirebase();
    await _requestPermissions();
    await _initLocalNotifications();
    await _getToken();
    _setListeners();
  }

  static Future<void> _initFirebase() async {
    await Firebase.initializeApp();
  }

  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print(' Notification permission denied');
    } else {
      print(' Notification permission granted');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);
  }

  static Future<void> _getToken() async {
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  static void _setListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              channelDescription: 'Default channel for app notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // this func when i press on notification it use like to navigate to page
    // (when app is on background) ....
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(' App opened by notification: ${message.notification?.title}');
    });

    // this func when i press on notification it use like to navigate to page
    // (when app is on terminated mean it is closed) ....
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print(
            ' App launched from notification: ${message.notification?.title}');
      }
    });
   }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling background message: ${message.messageId}');
  }
}
