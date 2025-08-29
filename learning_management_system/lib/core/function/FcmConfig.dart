// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
//
// requestPermissionsNotification() async {
//   NotificationSettings settings =
//       await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
// }
//
// void fcmConfig() {
//   FirebaseMessaging.onMessage.listen(
//     (message) async {
//       print(message.notification?.title);
//       print(message.notification?.body);
//
//       // Get.snackbar(message.notification?.title ?? 'No Title',
//       //     message.notification?.body ?? 'No Body');
//
//       if (message.notification != null) {
//         RemoteNotification notification = message.notification!;
//         AndroidNotification? android = message.notification?.android;
//         refreshNotificationOrderPage(message.data);
//
//         if (android != null) {
//           const AndroidNotificationDetails androidDetails =
//               AndroidNotificationDetails(
//             'your_channel_id',
//             'your_channel_name',
//             channelDescription: 'your_channel_description',
//             importance: Importance.max,
//             priority: Priority.high,
//             playSound: true,
//           );
//
//           const NotificationDetails platformDetails =
//               NotificationDetails(android: androidDetails);
//
//           final flutterLocalNotificationsPlugin =
//               Get.find<MyServices>().flutterLocalNotificationsPlugin;
//
//           await flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             platformDetails,
//           );
//         }
//       }
//     },
//   );
// }
//
//
//
