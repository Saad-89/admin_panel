import 'dart:typed_data';
import 'package:admin_panel/screens/tournament.dart';
import 'package:admin_panel/widgets/venueSelection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class OrganizeTournamentPage extends StatefulWidget {
  final Function(Tournament) onTournamentCreated;

  OrganizeTournamentPage({required this.onTournamentCreated});

  @override
  _OrganizeTournamentPageState createState() => _OrganizeTournamentPageState();
}

class _OrganizeTournamentPageState extends State<OrganizeTournamentPage> {
  String id = Uuid().v4();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  TextEditingController _teamsController = TextEditingController();
  TextEditingController _refereesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _venueController.dispose();
    _teamsController.dispose();
    _refereesController.dispose();
    super.dispose();
  }

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
        'id': doc.id,
        'name': doc['name'],
        'email': doc['email'],
        'age': doc['age'],
      };
    }).toList();
  }

  List<Map<dynamic, dynamic>> refereesData = [];

  @override
  void initState() {
    super.initState();
    fetchRefereesData().then((data) {
      setState(() {
        refereesData = data;
      });
    });
  }

  List<String> selectedReferees = [];
  List<String> selectedRefereesDocIds = [];

  Uint8List? _imageData;
  String? tournamentLogoUrl;

  bool isRefereeSelected = false;

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
  Widget build(BuildContext context) {
    print('here is the id $id');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_sharp)),
                        SizedBox(
                          width: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Club',
                              style: TextStyle(
                                  fontSize: 34,
                                  color: Color(0xff6858FE),
                                  fontFamily: 'karla',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Match',
                              style: TextStyle(
                                  fontSize: 34,
                                  color: Color(0xffFFA626),
                                  fontFamily: 'karla',
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 200,
                        ),
                        Text(
                          'Create New Tournament',
                          style: TextStyle(
                              fontFamily: 'karla',
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              color: Color(0xff2D2D2D)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1000,
                    child: Column(
                      children: [
                        GestureDetector(
                            onTap: _pickImage,
                            child: _imageData != null
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    width: 60,
                                    height: 60,
                                    child: Image.memory(_imageData!),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    width: 60,
                                    height: 60,
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Colors.grey,
                                    ),
                                  )),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Tournament Name',
                                style: TextStyle(
                                    fontSize: 26, fontFamily: 'karla'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
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
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontFamily: 'karla',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                readOnly: true,
                                controller: _dateController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEEEEEE),
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a date';
                                  }
                                  return null;
                                },
                                onTap: () {
                                  _showDatePicker(context);
                                },
                              ),
                            ),
                          ],
                        ),

                        // Row(
                        //   children: [
                        //     Expanded(
                        //       flex: 1,
                        //       child: Text(
                        //         'Date',
                        //         style: TextStyle(
                        //             fontSize: 26, fontFamily: 'karla'),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       flex: 2,
                        //       child: TextFormField(
                        //         readOnly: true,
                        //         controller: _dateController,
                        //         decoration: InputDecoration(
                        //           filled: true,
                        //           fillColor: Color(0xffEEEEEE),
                        //           // ignore: unnecessary_null_comparison
                        //           hintText: 'Select Date Of The Tournament',
                        //           hintStyle: TextStyle(
                        //             fontFamily: 'karla',
                        //           ),
                        //           border: OutlineInputBorder(),
                        //           enabledBorder: OutlineInputBorder(
                        //             borderSide: BorderSide(
                        //               width: 0.5,
                        //               color: Color(0xffEEEEEE),
                        //             ),
                        //           ),
                        //           focusedBorder: OutlineInputBorder(
                        //             borderSide: BorderSide(
                        //               color: Color(0xffEEEEEE),
                        //             ),
                        //           ),
                        //           suffixIcon: IconButton(
                        //             icon: Icon(
                        //               Icons.calendar_today,
                        //               color: Colors.black,
                        //             ),
                        //             onPressed: () {
                        //               _showDatePicker(context);
                        //             },
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Time',
                                style: TextStyle(
                                    fontSize: 26, fontFamily: 'karla'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _timeController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEEEEEE),
                                  hintText:
                                      'Enter Tournament Starting Time. e.g 7 Pm',
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
                                    return 'tournament time';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'No. Of Teams',
                                style: TextStyle(
                                    fontSize: 26, fontFamily: 'karla'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
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
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Venue',
                                style: TextStyle(
                                    fontSize: 26, fontFamily: 'karla'),
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: VenueBox(
                                  id: id,
                                )),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Referees",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontFamily: 'karla',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(3, (index) {
                                  return Container(
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Color(0xffEEEEEE),
                                      border: Border.all(
                                        color: Color(0xffEEEEEE),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String?>(
                                        padding: EdgeInsets.only(
                                          right: 8,
                                          left: 12,
                                          top: 8,
                                          bottom: 8,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        hint: Center(
                                            child: Text('Select a referee')),
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
                                                    selectedRefereesDocIds[
                                                        index] = newRefereeId;
                                                  } else {
                                                    selectedReferees
                                                        .add(refereeName);
                                                    selectedRefereesDocIds
                                                        .add(newRefereeId);
                                                  }
                                                }

                                                // Update the variable to indicate that at least one referee is selected
                                                isRefereeSelected = true;
                                              }
                                            }
                                          });
                                        },
                                        items: refereesData.where((referee) {
                                          return !selectedRefereesDocIds
                                                  .contains(referee['id']) ||
                                              (selectedRefereesDocIds.length >
                                                      index &&
                                                  selectedRefereesDocIds[
                                                          index] ==
                                                      referee['id']);
                                        }).map((referee) {
                                          return DropdownMenuItem<String>(
                                            value: referee['id'],
                                            child: Center(
                                                child: Text(referee['name'])),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),

                        // Row(
                        //   children: [
                        //     Expanded(
                        //       flex: 1,
                        //       child: Text(
                        //         "Referees",
                        //         style: TextStyle(
                        //             fontSize: 26, fontFamily: 'karla'),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       flex: 2,
                        //       child: Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,
                        //         children: List.generate(3, (index) {
                        //           return Container(
                        //             width: 200,
                        //             decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(15),
                        //               color: Color(0xffEEEEEE),
                        //               border: Border.all(
                        //                   color: Color(
                        //                       0xffEEEEEE)), // Border color
                        //             ),
                        //             child: DropdownButtonHideUnderline(
                        //                 // <-- Wrap your DropdownButton with this

                        //                 child: DropdownButton<String?>(
                        //               padding: EdgeInsets.only(
                        //                   right: 8,
                        //                   left: 12,
                        //                   top: 8,
                        //                   bottom: 8),
                        //               borderRadius: BorderRadius.circular(15),
                        //               hint: Center(
                        //                   child: Text('Select a referee')),
                        //               value: selectedReferees.length > index
                        //                   ? selectedRefereesDocIds[index]
                        //                   : null,
                        //               onChanged: (String? newRefereeId) {
                        //                 setState(() {
                        //                   if (newRefereeId != null) {
                        //                     Map<dynamic, dynamic>?
                        //                         selectedReferee;
                        //                     try {
                        //                       selectedReferee = refereesData
                        //                           .firstWhere((referee) =>
                        //                               referee['id'] ==
                        //                               newRefereeId);
                        //                     } catch (e) {
                        //                       // This means no referee was found with the given ID. Handle if needed.
                        //                     }

                        //                     if (selectedReferee != null) {
                        //                       String refereeName =
                        //                           selectedReferee['name'];

                        //                       if (selectedReferees
                        //                           .contains(refereeName)) {
                        //                         // Handle this case, if needed
                        //                       } else {
                        //                         if (selectedReferees.length >
                        //                             index) {
                        //                           selectedReferees[index] =
                        //                               refereeName;
                        //                           selectedRefereesDocIds[
                        //                               index] = newRefereeId;
                        //                         } else {
                        //                           selectedReferees
                        //                               .add(refereeName);
                        //                           selectedRefereesDocIds
                        //                               .add(newRefereeId);
                        //                         }
                        //                       }
                        //                     }
                        //                   }
                        //                 });
                        //               },
                        //               items: refereesData.where((referee) {
                        //                 return !selectedRefereesDocIds
                        //                         .contains(referee['id']) ||
                        //                     (selectedRefereesDocIds.length >
                        //                             index &&
                        //                         selectedRefereesDocIds[index] ==
                        //                             referee['id']);
                        //               }).map((referee) {
                        //                 return DropdownMenuItem<String>(
                        //                   value: referee[
                        //                       'id'], // This will ensure that the ID is what's returned upon selection
                        //                   child: Center(
                        //                       child: Text(referee['name'])),
                        //                 );
                        //               }).toList(),
                        //             )),
                        //           );
                        //         }),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                                    List<String> missingFields = [];

                                    if (!isRefereeSelected) {
                                      missingFields.add('At least one referee');
                                    }
                                    if (tournamentLogoUrl == null) {
                                      missingFields.add('Tournament Image');
                                    }
                                    // if (venueName == null) {
                                    //   missingFields.add('Venue');
                                    // }

                                    if (missingFields.isNotEmpty) {
                                      String errorMessage = 'Please select ';
                                      if (missingFields.length == 1) {
                                        errorMessage += missingFields.first;
                                      } else if (missingFields.length == 2) {
                                        errorMessage +=
                                            '${missingFields[0]} and ${missingFields[1]}';
                                      } else {
                                        for (int i = 0;
                                            i < missingFields.length - 1;
                                            i++) {
                                          errorMessage +=
                                              '${missingFields[i]}, ';
                                        }
                                        errorMessage = errorMessage.substring(
                                            0,
                                            errorMessage.length -
                                                2); // Remove the last comma and space
                                        errorMessage +=
                                            ' and ${missingFields.last}';
                                      }
                                      errorMessage += '.';

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(errorMessage),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                      return; // Return without proceeding if any field is missing
                                    }
                                    Tournament newTournament = Tournament(
                                      name: _nameController.text,
                                      date: _selectedDate.toString(),
                                      venue: _venueController.text,
                                      teams: _teamsController.text,
                                      referres: selectedReferees,
                                    );
                                    widget.onTournamentCreated(newTournament);
                                    firestore
                                        .collection('events')
                                        .doc(id)
                                        .update({
                                      'adminId': user!.uid,
                                      'name': _nameController.text,
                                      'date': _dateController.text.toString(),
                                      'time': _timeController.text,
                                      'teams': _teamsController.text,
                                      'referres': selectedReferees,
                                      'refereesDocIds': selectedRefereesDocIds,
                                      'tournamentLogo': tournamentLogoUrl,
                                    });

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Tournament Created Successfully'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
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
      ),
    );
  }
}
