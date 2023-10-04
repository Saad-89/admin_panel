import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class EditAnnouncement extends StatefulWidget {
  final String announcementId;

  EditAnnouncement({required this.announcementId});

  @override
  State<EditAnnouncement> createState() => _EditAnnouncementState();
}

class _EditAnnouncementState extends State<EditAnnouncement> {
  TextEditingController announcementController = TextEditingController();

  // String? newImage;
  // Uint8List? _imageData;
  // bool _imageSelected = false;

  @override
  void initState() {
    super.initState();
    // Initialize values for editing news
    initializeNewsForEditing();
  }

  Future<void> initializeNewsForEditing() async {
    try {
      // Fetch the existing news data by its ID
      final newsDoc = await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.announcementId)
          .get();

      if (newsDoc.exists) {
        final newsData = newsDoc.data() as Map<String, dynamic>;
        final announcementData = newsData['announcement'] as String;

        setState(() {
          announcementController.text = announcementData;
        });
      } else {
        // Handle the case where the news with the given ID does not exist
        print('Announcements not found.');
      }
    } catch (error) {
      // Handle any errors that occur during data retrieval
      print('Error initializing Announcement for editing: $error');
    }
  }

  void createAnnouncement() {
    final AnnouncementContent = announcementController.text.trim();

    List<String> emptyFields = [];
    if (AnnouncementContent.isEmpty) emptyFields.add('Announcement');

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
      'announcement': AnnouncementContent,
      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp field
    };

    FirebaseFirestore.instance
        .collection('announcements')
        .doc(widget.announcementId)
        .update(newsData)
        .then((value) {
      print('Announcement updated successfully.');
      _showSnackBar('Announcement updated successfully', Colors.green);
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to updated Announcement: $error');
      _showSnackBar('Failed to updated Announcement', Colors.red);
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
                Text('Update Announcement',
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
                    'Update',
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
