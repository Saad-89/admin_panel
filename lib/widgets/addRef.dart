import 'dart:typed_data';
import 'package:admin_panel/screens/refrees.dart';
import 'package:admin_panel/screens/tournament.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:path/path.dart' as path;

class AddRefDialogue extends StatefulWidget {
  final Function(Referees)? onTournamentCreated;
  final String? tournamentId;

  AddRefDialogue({this.onTournamentCreated, this.tournamentId});

  @override
  _AddRefDialogueState createState() => _AddRefDialogueState();
}

class _AddRefDialogueState extends State<AddRefDialogue> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();
  TextEditingController _specilationController = TextEditingController();

  Uint8List? _imageData;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _specilationController.dispose();
    super.dispose();
  }

  String? _refId;
  String? refImageUrl;

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
      await Future.delayed(Duration(seconds: 2));
      // Get the download URL of the uploaded image
      final downloadURL = await snapshot.ref.getDownloadURL();
      print('URL: $downloadURL');

      setState(() {
        refImageUrl = downloadURL;
      });
    }
  }

  String? _selectedSpecialization;
  List<String> _specializations = [
    'Football',
    'Cricket',
    'Boxing',
    'Vollyball',
  ];

  String? _selectedExperience;
  List<String> _experiences = [
    '0-1 years',
    '1-3 years',
    '3-5 years',
    '5+ years',
  ];

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Text(
                        'Create New Referee',
                        style: TextStyle(
                            fontFamily: 'karla',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xff2D2D2D)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // select image ...
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.deepPurpleAccent)),
                              onPressed: _pickImage,
                              child: _imageData != null
                                  ? Text('Image Picked')
                                  : Text('Pick Image'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEEEEEE),
                                hintText: 'Enter Name Of The Referee',
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
                      // email..........
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEEEEEE),
                                hintText: 'Enter Email Of The Referee',
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
                      // age............
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _ageController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEEEEEE),
                                hintText: 'Enter Age Of The Referee',
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
                                  return 'Please enter age';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // experiance....
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedExperience,
                              hint: Text('Select experience Of The Referee'),
                              decoration: InputDecoration(
                                hintText: 'Select experience',
                                hintStyle: TextStyle(
                                  fontFamily: 'karla',
                                ),
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
                              items: _experiences.map((String experience) {
                                return DropdownMenuItem<String>(
                                  value: experience,
                                  child: Text(experience),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedExperience = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select experience';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      // specilization...
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedSpecialization,
                              hint: Text('Select a specialization'),
                              decoration: InputDecoration(
                                hintText: 'Select a specialization',
                                hintStyle: TextStyle(
                                  fontFamily: 'karla',
                                ),
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
                              items:
                                  _specializations.map((String specialization) {
                                return DropdownMenuItem<String>(
                                  value: specialization,
                                  child: Text(specialization),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSpecialization = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a specialization';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // address....
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                hintText: 'Enter Ref Address',
                                hintStyle: TextStyle(
                                  fontFamily: 'karla',
                                ),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter ref address';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: 10),
                      // // select image ...
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       flex: 2,
                      //       child: ElevatedButton(
                      //         style: ButtonStyle(
                      //             backgroundColor: MaterialStatePropertyAll(
                      //                 Colors.deepPurpleAccent)),
                      //         onPressed: _pickImage,
                      //         child: _imageData != null
                      //             ? Text('Image Picked')
                      //             : Text('Pick Image'),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.grey[200]),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Close',
                                style: TextStyle(color: Colors.black),
                              )),
                          SizedBox(
                            width: 15,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.deepPurpleAccent),
                            ),
                            onPressed: _isSaving
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (_imageData == null) {
                                        // Show a SnackBar if the image is not selected
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Please select an image for the referee'),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                        return; // Return early to avoid further processing
                                      }
                                      setState(() {
                                        _isSaving =
                                            true; // Start the saving process
                                      });
                                      // Create the new referee first
                                      final refDoc = FirebaseFirestore.instance
                                          .collection('referees')
                                          .doc();
                                      _refId = refDoc.id;

                                      await refDoc.set({
                                        'adminId': user!.uid,
                                        'id': _refId,
                                        'name': _nameController.text,
                                        'email': _emailController.text,
                                        'age': _ageController.text,
                                        'address': _addressController.text,
                                        'experience': _selectedExperience,
                                        'specialization':
                                            _selectedSpecialization,
                                        'refImage': refImageUrl
                                      });

                                      // Now, add the referee's ID to the tournament's refereesDocIds array
                                      final tournamentDocRef = firestore
                                          .collection('events')
                                          .doc(widget.tournamentId);

                                      try {
                                        await tournamentDocRef.update({
                                          'refereesDocIds':
                                              FieldValue.arrayUnion([_refId!])
                                        });
                                      } catch (e) {
                                        print("Error updating tournament: $e");
                                        if (e is Error) {
                                          print(
                                              "Tournament document does not exist. You might want to handle this differently!");
                                        }
                                      }

                                      // If you have the Referees class instance creation and callback,
                                      // I've kept them here for your reference:
                                      Referees newReferee = Referees(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        age: _ageController.text,
                                        address: _addressController.text,
                                        experience:
                                            _selectedExperience.toString(),
                                        specialization:
                                            _selectedSpecialization.toString(),
                                        id: _refId!,
                                      );
                                      if (widget.onTournamentCreated != null) {
                                        widget.onTournamentCreated!(newReferee);
                                      }

                                      setState(() {
                                        _isSaving =
                                            false; // End the saving process
                                      });

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Referee added successfully'),
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
                            child: _isSaving
                                ? Center(
                                    child: CircularProgressIndicator(
                                      // Show loader when _isSaving is true

                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'SAVE',
                                    style: TextStyle(fontFamily: 'karla'),
                                  ),
                          ),

                          // ElevatedButton(
                          //   style: ButtonStyle(
                          //     shape: MaterialStatePropertyAll(
                          //         RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(15))),
                          //     backgroundColor: MaterialStateProperty.all(
                          //         Colors.deepPurpleAccent),
                          //   ),
                          //   onPressed: () async {
                          //     if (_formKey.currentState!.validate()) {
                          //       Referees newTournament = Referees(
                          //         name: _nameController.text,
                          //         email: _emailController.text,
                          //         age: _ageController.text,
                          //         address: _addressController.text,
                          //         experience: _selectedExperience.toString(),
                          //         specialization:
                          //             _selectedSpecialization.toString(),
                          //         id: _refId!,
                          //       );
                          //       widget.onTournamentCreated!(newTournament);

                          //       final docRef =
                          //           firestore.collection('referees').doc();
                          //       _refId = docRef.id;

                          //       await docRef.set({
                          //         'adminId': user!.uid,
                          //         'id': _refId,
                          //         'name': _nameController.text,
                          //         'email': _emailController.text,
                          //         'age': _ageController.text,
                          //         'address': _addressController.text,
                          //         'experience': _selectedExperience,
                          //         'specialization': _selectedSpecialization,
                          //         'refImage': refImageUrl
                          //       });

                          //       Navigator.pop(context);
                          //     }
                          //   },
                          //   child: Text(
                          //     'SAVE',
                          //     style: TextStyle(fontFamily: 'karla'),
                          //   ),
                          // ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
