import 'package:admin_panel/screens/tournament.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

import '../venueSelection.dart';

class EditTournamentDialog extends StatefulWidget {
  final Tournament tournament;
  final Function(Tournament)? onTournamentCreated;

  EditTournamentDialog({required this.tournament, this.onTournamentCreated});

  @override
  _EditTournamentDialogState createState() => _EditTournamentDialogState();
}

class _EditTournamentDialogState extends State<EditTournamentDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _teamsController = TextEditingController();
  TextEditingController _refereesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  Future<void> _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  // for selecting ref...........
  Future<List<Map<dynamic, dynamic>>> fetchRefereesData() async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('referees').get();

    return querySnapshot.docs.map((DocumentSnapshot doc) {
      return {
        'id': doc.id, // This is the document ID.
        'name': doc['name'],
        'email': doc['email'],
        'age': doc['age'],
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.tournament.name;
    _dateController.text = widget.tournament.date;
    _venueController.text = widget.tournament.venue;
    _teamsController.text = widget.tournament.teams;
    if (widget.tournament.tournamentLogo != null) {
      tournamentLogoUrl = widget.tournament.tournamentLogo;
      // You can also fetch the Uint8List data of the image if needed using the URL.
      // However, for displaying, the URL should suffice. You will need the Uint8List only if you intend to edit or manipulate the image.
    }

    if (widget.tournament.referres != null) {
      selectedReferees = List<String>.from(widget.tournament.referres!);
    }
// Assuming you also have refereesDocIds in your Tournament model
    if (widget.tournament.refereesDocIds != null) {
      selectedRefereesDocIds =
          List<String>.from(widget.tournament.refereesDocIds!);
    }

    fetchRefereesData().then((data) {
      setState(() {
        refereesData = data;
      });
    });
  }

  List<Map<dynamic, dynamic>> refereesData = [];

  List<String> selectedReferees = [];
  List<String> selectedRefereesDocIds = [];

  Uint8List? _imageData;
  String? tournamentLogoUrl;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePickerWeb.getImageInfo;
    if (pickedImage != null) {
      setState(() {
        _imageData = pickedImage.data! as Uint8List;
      });

      final fileName = path.basename(pickedImage.fileName!);
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('ref_images/$fileName');
      final uploadTask = firebaseStorageRef.putData(_imageData!);
      final snapshot = await uploadTask;

      // Get the download URL of the uploaded image
      final downloadURL = await snapshot.ref.getDownloadURL();
      print('URL: $downloadURL');

      setState(() {
        tournamentLogoUrl = downloadURL;
      });

      // Use the download URL as needed (e.g., save it to Firestore)
      // ...
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _venueController.dispose();
    _teamsController.dispose();
    _refereesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "EDIT TOURNAMENT",
        style: TextStyle(
            fontFamily: 'karla', fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 700,
                  child: Column(
                    children: [
                      GestureDetector(
                          onTap: _pickImage,
                          child: tournamentLogoUrl != null
                              ? Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  width: 60,
                                  height: 60,
                                  child: Image.network(tournamentLogoUrl!,
                                      scale: 1))
                              : Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  width: 60,
                                  height: 60,
                                  child: Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.grey,
                                  ),
                                )),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEEEEEE),
                                hintText: 'Enter Name Of The Tournament',
                                hintStyle: TextStyle(
                                  fontFamily: 'karla',
                                ),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: _dateController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEEEEEE),
                                // ignore: unnecessary_null_comparison
                                hintText: 'Select Date Of The Tournament',
                                hintStyle: TextStyle(
                                  fontFamily: 'karla',
                                ),
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
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _showDatePicker(context);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _teamsController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEEEEEE),
                                hintText:
                                    'Enter Number Of Teams Participating In Tournament',
                                hintStyle: TextStyle(
                                  fontFamily: 'karla',
                                ),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Number of teams participating in tournament';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: VenueBox(
                            id: widget.tournament.id,
                          )),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(3, (index) {
                                return Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(0xffEEEEEE),
                                    border: Border.all(
                                        color:
                                            Color(0xffEEEEEE)), // Border color
                                  ),
                                  child: DropdownButtonHideUnderline(
                                      // <-- Wrap your DropdownButton with this

                                      child: DropdownButton<String?>(
                                    padding: EdgeInsets.only(
                                        right: 8, left: 12, top: 8, bottom: 8),
                                    borderRadius: BorderRadius.circular(15),
                                    hint:
                                        Center(child: Text('Select a referee')),
                                    value: selectedReferees.length > index
                                        ? selectedRefereesDocIds[index]
                                        : null,
                                    onChanged: (String? newRefereeId) {
                                      setState(() {
                                        if (newRefereeId != null) {
                                          Map<dynamic, dynamic>?
                                              selectedReferee;
                                          try {
                                            selectedReferee = refereesData
                                                .firstWhere((referee) =>
                                                    referee['id'] ==
                                                    newRefereeId);
                                          } catch (e) {
                                            // This means no referee was found with the given ID. Handle if needed.
                                          }

                                          if (selectedReferee != null) {
                                            String refereeName =
                                                selectedReferee['name'];

                                            if (selectedReferees
                                                .contains(refereeName)) {
                                              // Handle this case, if needed
                                            } else {
                                              if (selectedReferees.length >
                                                  index) {
                                                selectedReferees[index] =
                                                    refereeName;
                                                selectedRefereesDocIds[index] =
                                                    newRefereeId;
                                              } else {
                                                selectedReferees
                                                    .add(refereeName);
                                                selectedRefereesDocIds
                                                    .add(newRefereeId);
                                              }
                                            }
                                          }
                                        }
                                      });
                                    },
                                    items: refereesData.where((referee) {
                                      return !selectedRefereesDocIds
                                              .contains(referee['id']) ||
                                          (selectedRefereesDocIds.length >
                                                  index &&
                                              selectedRefereesDocIds[index] ==
                                                  referee['id']);
                                    }).map((referee) {
                                      return DropdownMenuItem<String>(
                                        value: referee[
                                            'id'], // This will ensure that the ID is what's returned upon selection
                                        child: Center(
                                            child: Text(referee['name'])),
                                      );
                                    }).toList(),
                                  )),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 40,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Color(0xffEEEEEE),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xffEEEEEE)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'CLOSE',
                                style: TextStyle(
                                    fontFamily: 'karla', color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Container(
                            height: 40,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Color(0xff6858FE),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xff6858FE)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Tournament newTournament = Tournament(
                                    name: _nameController.text,
                                    date: _selectedDate.toString(),
                                    venue: _venueController.text,
                                    teams: _teamsController.text,
                                    referres: selectedReferees,
                                  );
                                  // widget.onTournamentCreated!(newTournament);
                                  firestore
                                      .collection('events')
                                      .doc(widget.tournament.id)
                                      .update({
                                    'adminId': user!.uid,
                                    'name': _nameController.text,
                                    'date': _dateController.text.toString(),
                                    'teams': _teamsController.text,
                                    'referres': selectedReferees,
                                    'refereesDocIds': selectedRefereesDocIds,
                                    'tournamentLogo': tournamentLogoUrl,
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Tournament Updated Successfully',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor: Colors.yellow,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );

                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'SAVE',
                                style: TextStyle(fontFamily: 'karla'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// firestore
//     .collection('events')
//     .doc(widget.tournament.id)
//     .update({
//   'adminId': user!.uid,
//   'name': _nameController.text,
//   'date': _dateController.text.toString(),
//   'teams': _teamsController.text,
//   'referres': selectedReferees.toString(),
//   'tournamentLogo': tournamentLogoUrl,
// });

// DropdownButton<String?>(
//   padding: EdgeInsets.only(
//       right: 8,
//       left: 12,
//       top: 8,
//       bottom: 8),
//   borderRadius: BorderRadius.circular(15),
//   hint: Center(
//       child: Text(
//           textAlign: TextAlign.center,
//           'Select a referee')),
//   value: selectedReferees.length > index
//       ? selectedReferees[index]
//       : null,
//   onChanged: (String? newValue) {
//     setState(() {
//       if (newValue != null) {
//         if (selectedReferees
//             .contains(newValue)) {
//           // Display a message or handle this case
//         } else {
//           if (selectedReferees.length >
//               index) {
//             selectedReferees[index] =
//                 newValue;
//           } else {
//             selectedReferees.add(newValue!);
//           }
//         }
//       }
//     });
//   },
//   items: refereesData.where((referee) {
//     // Referee should not be in the selected list (except for the current dropdown)
//     return !selectedReferees
//             .contains(referee['name']) ||
//         (selectedReferees.length > index &&
//             selectedReferees[index] ==
//                 referee['name']);
//   }).map((referee) {
//     return DropdownMenuItem<String>(
//       value: referee['name'],
//       child: Center(
//           child: Text(referee['name'])),
//     );
//   }).toList(),
// ),

// actions: [
//   ElevatedButton(
//     style: ButtonStyle(
//         backgroundColor:
//             MaterialStatePropertyAll(Colors.deepPurpleAccent)),
//     onPressed: () {
//       Navigator.of(context).pop();
//     },
//     child: Text('Cancel'),
//   ),
//   ElevatedButton(
//     style: ButtonStyle(
//         backgroundColor:
//             MaterialStatePropertyAll(Colors.deepPurpleAccent)),
//     onPressed: () async {
//       if (_formKey.currentState!.validate()) {
//         Tournament editedTournament = Tournament(
//           id: widget.tournament.id,
//           name: _nameController.text,
//           date: _dateController.text,
//           venue: _venueController.text,
//           teams: _teamsController.text,
//         );
//         final docRef =
//             firestore.collection('events').doc(widget.tournament.id);
//         await docRef.update({
//           'name': _nameController.text,
//           'date': _dateController.text,
//           'venue': _venueController.text,
//           'teams': _teamsController.text,
//         });
//         Navigator.pop(context, editedTournament);
//       }
//     },
//     child: Text('Save'),
//   ),
// ],

// Form(
//   key: _formKey,
//   child: SingleChildScrollView(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: _nameController,
//           decoration: InputDecoration(
//             hintText: 'Enter Tournament Name',
//             hintStyle: TextStyle(
//               fontFamily: 'karla',
//             ),
//             border: OutlineInputBorder(),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 width: 0.5,
//                 color: Colors.blueGrey,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 color: Colors.blueGrey,
//               ),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter a name';
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 15),
//         TextFormField(
//           controller: _dateController,
//           decoration: InputDecoration(
//             hintText: 'Enter Tournament Date',
//             hintStyle: TextStyle(
//               fontFamily: 'karla',
//             ),
//             border: OutlineInputBorder(),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 width: 0.5,
//                 color: Colors.blueGrey,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 color: Colors.blueGrey,
//               ),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter tournament date';
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 15),
//         TextFormField(
//           controller: _venueController,
//           decoration: InputDecoration(
//             hintText: 'Enter Tournament venue',
//             hintStyle: TextStyle(
//               fontFamily: 'karla',
//             ),
//             border: OutlineInputBorder(),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 width: 0.5,
//                 color: Colors.blueGrey,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 color: Colors.blueGrey,
//               ),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter tournament venue';
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 15),
//         TextFormField(
//           controller: _teamsController,
//           decoration: InputDecoration(
//             hintText: 'Enter Referee Address',
//             hintStyle: TextStyle(
//               fontFamily: 'karla',
//             ),
//             border: OutlineInputBorder(),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 width: 0.5,
//                 color: Colors.blueGrey,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 color: Colors.blueGrey,
//               ),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter referee address';
//             }
//             return null;
//           },
//         ),
//       ],
//     ),
//   ),
// ),
