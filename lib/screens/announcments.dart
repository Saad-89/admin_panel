import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/announcement/announcementList.dart';
import '../widgets/announcement/createAnnouncement.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Announcements',
                  style: TextStyle(
                      fontFamily: 'karla',
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Color(0xff2D2D2D)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepPurpleAccent),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CreateAnnouncement();
                          },
                        );
                      },
                      child: Text(
                        'Create Announcement',
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'karla',
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: AnnouncementsList(),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../util/notificationService/notificationServices.dart';

// class AnnouncementScreen extends StatefulWidget {
//   const AnnouncementScreen({Key? key}) : super(key: key);

//   @override
//   State<AnnouncementScreen> createState() => _AnnouncementScreenState();
// }

// class _AnnouncementScreenState extends State<AnnouncementScreen> {
//   NotificationServices notificationServices = NotificationServices();

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Notifications'),
//       ),
//       body: Center(
//         // child: TextButton(
//         //   onPressed: () async {
//         //     // send notification from one device to another
          //   var data = {
          //     'to':
          //         'cxnTDRCrQde5yIHgUvp7sZ:APA91bGC1ZAt4fME6FcVMPxHLkWJ8TrOamk0J1VEP0Cyyf_2wINM8HB-_f5z-xMfjrUA0NW0DUjpYUuOsGRQJtl5SHZ_p1oi2d_zDOCyI0x5efz1De-4ONPN0aOEibqFuEgOAcg6us6h',
          //     'notification': {
          //       'title': 'Announcement',
          //       'body': 'This is announcements!',
          //       "sound": "jetsons_doorbell.mp3"
          //     },
          //     'android': {
          //       'notification': {
          //         'notification_count': 23,
          //       },
          //     },
          //     'data': {'type': 'msj', 'id': 'Asif Taj'}
          //   };

          //   await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          //       body: jsonEncode(data),
          //       headers: {
          //         'Content-Type': 'application/json; charset=UTF-8',
          //         'Authorization':
          //             'key=AAAATgLxsNA:APA91bF-2bpAKc0MeEp9oqQSVozyVaK3kgdSe0MxxMZw2sTGWQ0fORTUGBVobrSwYF7asGrmBfThqsfTb1zWjT--MbEawrAHNbETStCNrRj_gBElKs2zcVT0-yVvM6RLa_DcnO83INTi'
          //       }).then((value) {
          //     if (kDebugMode) {
          //       print(value.body.toString());
          //     }
          //   }).onError((error, stackTrace) {
          //     if (kDebugMode) {
          //       print(error);
          //     }
          //   });
          // },
//         //   child: Text('Send Notifications'),
//         // ),
//       ),
//     );
//   }
// }
