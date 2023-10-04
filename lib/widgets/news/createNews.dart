import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:rxdart/rxdart.dart';

class CreateNews extends StatefulWidget {
  const CreateNews({super.key});

  @override
  State<CreateNews> createState() => _CreateNewsState();
}

class _CreateNewsState extends State<CreateNews> {
  TextEditingController newsContentController = TextEditingController();

  String? newImage;
  Uint8List? _imageData;
  bool _imageSelected = false;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePickerWeb.getImageInfo;
    if (pickedImage != null) {
      setState(() {
        _imageData = pickedImage.data! as Uint8List;
      });

      final fileName = path.basename(pickedImage.fileName!);
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('news_images/$fileName');
      final uploadTask = firebaseStorageRef.putData(_imageData!);
      final snapshot = await uploadTask;

      // Get the download URL of the uploaded image
      final downloadURL = await snapshot.ref.getDownloadURL();
      print('URL: $downloadURL');

      setState(() {
        newImage = downloadURL;
        _imageSelected = true;
      });

      // Use the download URL as needed (e.g., save it to Firestore)
      // ...
    }
  }

  void createNews() {
    final newsContent = newsContentController.text.trim();

    List<String> emptyFields = [];
    if (newsContent.isEmpty) emptyFields.add('News Content');
    if (newImage == null) emptyFields.add('News Image');

    if (emptyFields.isNotEmpty) {
      String errorMessage;
      if (emptyFields.length > 3) {
        errorMessage = 'Please fill in the fields';
      } else if (emptyFields.length == 1) {
        errorMessage = 'Please select the ${emptyFields[0]} field';
      } else {
        errorMessage =
            'Please fill in or select the following fields:\n${emptyFields.join(', ')}';
      }
      _showSnackBar(errorMessage, Colors.red);
      return;
    }

    final newsData = {
      'newsContent': newsContent,
      'newsLogo': newImage,
      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp field
    };

    FirebaseFirestore.instance.collection('news').add(newsData).then((value) {
      print('News added successfully.');
      _showSnackBar('News created successfully', Colors.green);
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to add New: $error');
      _showSnackBar('Failed to create News', Colors.red);
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
                Text('Create News',
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
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'News Image',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: _imageData != null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: _imageSelected
                                        ? Image.memory(
                                            _imageData!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : CircularProgressIndicator(
                                            color: Color(0xffFFA626),
                                          ), // Show a loading indicator
                                  ),
                                )
                              : Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Color(0xff6858FE),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                        child: Text('Pick Image',
                                            style: TextStyle(
                                                color: Colors.white))),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'News Content',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller:
                              newsContentController, // Use your news content controller here
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
                    createNews();
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
