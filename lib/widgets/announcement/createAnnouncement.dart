import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateAnnouncement extends StatefulWidget {
  const CreateAnnouncement({super.key});

  @override
  State<CreateAnnouncement> createState() => _CreateAnnouncementState();
}

class _CreateAnnouncementState extends State<CreateAnnouncement> {
  TextEditingController announcementController = TextEditingController();

  void createAnnouncement() {
    final announcementContent = announcementController.text.trim();

    List<String> emptyFields = [];
    if (announcementContent.isEmpty) emptyFields.add('Announcement');

    if (emptyFields.isNotEmpty) {
      String errorMessage;
      if (emptyFields.length > 3) {
        errorMessage = 'Please fill in the fields';
      } else if (emptyFields.length == 1) {
        errorMessage = 'Please fill the ${emptyFields[0]} field';
      } else {
        errorMessage =
            'Please fill in the following fields:\n${emptyFields.join(', ')}';
      }
      _showSnackBar(errorMessage, Colors.red);
      return;
    }

    final newsData = {
      'announcement': announcementContent,

      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp field
    };

    FirebaseFirestore.instance
        .collection('announcements')
        .add(newsData)
        .then((value) {
      print('announcement added successfully.');
      _showSnackBar('announcement created successfully', Colors.green);
      sendNotification(announcementContent);
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to add New: $error');
      _showSnackBar('Failed to create announcement', Colors.red);
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // void sendNotification(String announcementContent) async {
  //   var data = {
  //     'to':
  //         'cxnTDRCrQde5yIHgUvp7sZ:APA91bGC1ZAt4fME6FcVMPxHLkWJ8TrOamk0J1VEP0Cyyf_2wINM8HB-_f5z-xMfjrUA0NW0DUjpYUuOsGRQJtl5SHZ_p1oi2d_zDOCyI0x5efz1De-4ONPN0aOEibqFuEgOAcg6us6h',
  //     'notification': {
  //       'title': 'Announcement',
  //       'body': announcementContent,
  //       "sound": "jetsons_doorbell.mp3"
  //     },
  //     'android': {
  //       'notification': {
  //         'channel_id': 1,
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
  // }

  Future<void> sendNotification(String announcementContent) async {
    // Retrieve the list of device IDs from Firestore
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot usersSnapshot = await usersCollection.get();

    // Extract device IDs from Firestore and handle null or empty values
    List<String> deviceIds = usersSnapshot.docs
        .map((doc) => ((doc.data() as Map<String, dynamic>?)?['deviceId'] ?? '')
            as String)
        .where((deviceId) => deviceId.isNotEmpty)
        .toList();

    // Iterate over device IDs and send notifications
    for (String deviceId in deviceIds) {
      var data = {
        'to': deviceId,
        'notification': {
          'title': 'Announcement',
          'body': announcementContent,
          'sound': 'jetsons_doorbell.mp3'
        },
        'android': {
          'notification': {
            'channel_id': '1',
            'notification_count': 23,
          },
        },
        'data': {'type': 'msj', 'id': 'Asif Taj'}
      };

      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAATgLxsNA:APA91bF-2bpAKc0MeEp9oqQSVozyVaK3kgdSe0MxxMZw2sTGWQ0fORTUGBVobrSwYF7asGrmBfThqsfTb1zWjT--MbEawrAHNbETStCNrRj_gBElKs2zcVT0-yVvM6RLa_DcnO83INTi'
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        // height: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Create Announcement',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Announcement',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller:
                              announcementController, // Use your news content controller here
                          maxLines:
                              4, // Allow multiple lines of text for content
                          decoration: InputDecoration(
                            // labelText:
                            //     'News Content', // Add a label for the content field
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 0.5,
                                color: Color(0xffEEEEEE),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffEEEEEE),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Color(0xff6858FE))),
                  onPressed: () {
                    createAnnouncement();
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(fontFamily: 'karla'),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Color(0xffEEEEEE))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black, fontFamily: 'karla'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
