import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_notifications_example/message_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User gave notification permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("User gave provisional notification permission");
    } else {
      print("User denied notification permission");
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  void initLocalNotifications(BuildContext context, RemoteMessage message) async {
    var androidInitialisation = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosdInitialisation = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(android: androidInitialisation, iOS: iosdInitialisation);
    await _flutterLocalNotificationsPlugin.initialize(initializationSetting, onDidReceiveNotificationResponse: (payload) {
      handleMessageClickListener(context, message);
    });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      print(message.data.toString());
      print(message.data["type"].toString());
      print(message.data["id"].toString());
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
      }
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
      Random.secure().nextInt(1000).toString(),
      "Flutter Notification",
    );
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      androidNotificationChannel.id,
      androidNotificationChannel.name,
      channelDescription: "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      ticker: "tikcer",
    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: darwinNotificationDetails);
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        1,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  void handleMessageClickListener(BuildContext context, RemoteMessage message) {
    if (message.data["type"] == "msg") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageScreen(
            id: message.data["id"],
          ),
        ),
      );
    }
  }

  Future<void> setupInteractMessageListener(BuildContext context) async {
    //when app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessageClickListener(context, initialMessage);
    }

    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessageClickListener(context, message);
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}
