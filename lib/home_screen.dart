import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_firebase_notifications_example/notification_services.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    // notificationServices.isTokenRefresh();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessageListener(context);
    notificationServices.getDeviceToken().then((value) {
      print("Device Token: $value");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: Text("Firebase Notifications")),
      body: Center(
        child: TextButton(
          onPressed: () {
            notificationServices.getDeviceToken().then((value) async {
              print("Device Token: $value");
              var data = {
                "to": value.toString(),
                "priority": "high",
                "notification": {"title": "Siva Teja Vajja", "body": "This is a message send using fcm apis"},
                "data": {
                  "type": "msg",
                  "id": "Siva Teja 453",
                }
              };
              http.post(
                Uri.parse("https://fcm.googleapis.com/fcm/send"),
                body: jsonEncode(data),
                headers: {"Content-Type": "application/json; charset=UTF-8", "Authorization": "key=AAAA6YYktY8:APA91bH6Whbc6NN3XK3Q33UExoru0Uphfqej9pLd4SGAx_HYElPbIJc_5lLLLJ8Zt8swwAzOUovbfxAk_g0PMrX-5TNXCxgEg2jhCoOOvVpcImfCXVdOt7uvySj7cVi12G4E7ck1aV4l"},
              );
            });
          },
          child: Text("Send Notification"),
        ),
      ),
    );
  }
}
