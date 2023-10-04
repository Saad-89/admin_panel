import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'editNewsScreen.dart';

class NewsList extends StatelessWidget {
  void editNews(BuildContext context, String newsId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditNews(newsId: newsId);
      },
    );
  }

  // Function to delete a news item
  void deleteNews(BuildContext context, String newsId) async {
    try {
      await FirebaseFirestore.instance.collection('news').doc(newsId).delete();
      _showSnackBar('News deleted successfully', Colors.red);
    } catch (error) {
      print('Failed to delete news: $error');
      _showSnackBar('Failed to delete news', Colors.red);
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
          .collection('news')
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

        final newsList = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.8, // Adjust this value to control the height
          ),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index].data() as Map<String, dynamic>;
            final newsId = newsList[index].id;
            final newsContent = news['newsContent'] as String;
            final newsLogoUrl = news['newsLogo'] as String;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Color(0xffFFF9F0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xffFFA626), width: 2),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage('$newsLogoUrl')),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      newsContent,
                      style: TextStyle(fontSize: 16, fontFamily: 'karla'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
