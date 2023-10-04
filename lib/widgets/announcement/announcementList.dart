import 'dart:js';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editAnnouncement.dart';

class AnnouncementsList extends StatelessWidget {
  void editNews(BuildContext context, String annouoncementId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAnnouncement(
          announcementId: annouoncementId,
        );
      },
    );
  }

  // Function to delete a news item
  void deleteNews(BuildContext context, String newsId) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(newsId)
          .delete();
      _showSnackBar('announcement deleted successfully', Colors.red);
    } catch (error) {
      print('Failed to delete announcement: $error');
      _showSnackBar('Failed to delete announcement', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          );
        }

        final announcementList = snapshot.data!.docs;

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: announcementList.length,
          itemBuilder: (context, index) {
            final announcements =
                announcementList[index].data() as Map<String, dynamic>;
            final newsId = announcementList[index].id;
            final newsContent = announcements['announcement'] as String;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Color(0xffFFF9F0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Row(
                    //   children: [
                    //     Text(
                    //       '$newsContent',
                    //       textAlign: TextAlign.justify,
                    //       style: TextStyle(fontSize: 16, fontFamily: 'karla'),
                    //     ),
                    //   ],
                    // ),
                    Flexible(
                      child: Text(
                        '$newsContent',
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 16, fontFamily: 'karla'),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            editNews(context, newsId);
                          },
                          child: Text("Edit",
                              style: TextStyle(
                                  color: Color(0xff6858FE), fontSize: 18)),
                        ),
                        TextButton(
                          onPressed: () async {
                            deleteNews(context, newsId);
                          },
                          child: Text("Delete",
                              style: TextStyle(
                                  color: Color(0xff6858FE), fontSize: 18)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
