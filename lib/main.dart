import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:post_house_rent_app/notification.dart';
import 'package:post_house_rent_app/notification.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: Platform.isAndroid
        ? FirebaseOptions(
            apiKey: "AIzaSyDZgvD5Lm6J4h_-ZtR6cSZeQ_aJ4tXWSB4",
            appId: "1:450381837508:android:47e5a1d755a05057ae8591",
            messagingSenderId: "450381837508",
            projectId: "450381837508",
            storageBucket: "post-room-house-rent.appspot.com",
          )
        : null,
  );

  // Khởi tạo và lên lịch thông báo;
  await notification.init();
  // await notification.showInstantNotification(
  //     "Chào buổi sáng!", "Chúc bạn một ngày tốt lành!");
  await notification.scheduleDailyMorningNotification(
    "Chào buổi sáng!",
    "Hãy !",
  );

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
