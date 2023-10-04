import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:rxdart/rxdart.dart';

class Captain {
  final String id;
  final String name;

  Captain({required this.id, required this.name});
}

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Teams',
                    style: TextStyle(
                        fontFamily: 'karla',
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Color(0xff2D2D2D)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.deepPurpleAccent),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CreateTeamDialog();
                            },
                          );
                        },
                        child: Text(
                          'Create Team',
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
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  TeamsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// create teams

class CreateTeamDialog extends StatefulWidget {
  // final String tournamentId;

  // CreateTeamDialog({this.tournamentId});

  @override
  _CreateTeamDialogState createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<CreateTeamDialog> {
  late TextEditingController teamNameController;
  late TextEditingController captainNameController;
  late TextEditingController PhoneNumberController;
  late TextEditingController emailController;
  late TextEditingController tagLineController;
  late TextEditingController clubNameController;

  String? _selectedCaptainId;
  String? _selectedCaptainName;

  @override
  void initState() {
    super.initState();
    teamNameController = TextEditingController();
    captainNameController = TextEditingController();
    PhoneNumberController = TextEditingController();
    emailController = TextEditingController();
    tagLineController = TextEditingController();
    clubNameController = TextEditingController();
  }

  @override
  void dispose() {
    teamNameController.dispose();
    captainNameController.dispose();
    PhoneNumberController.dispose();
    emailController.dispose();
    tagLineController.dispose();
    clubNameController.dispose();
    super.dispose();
  }

  Uint8List? _imageData;
  String? teamLogoUrl;
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
          .child('admin_teams/$fileName');
      final uploadTask = firebaseStorageRef.putData(_imageData!);
      final snapshot = await uploadTask;

      // Get the download URL of the uploaded image
      final downloadURL = await snapshot.ref.getDownloadURL();
      print('URL: $downloadURL');

      setState(() {
        teamLogoUrl = downloadURL;
      });

      // Use the download URL as needed (e.g., save it to Firestore)
      // ...
    }
  }

// captains without teams...
  Future<List<Captain>> _fetchCaptainsWithoutTeams() async {
    List<Captain> availableCaptains = [];
    QuerySnapshot captainsSnapshot =
        await FirebaseFirestore.instance.collection('captains').get();
    for (var doc in captainsSnapshot.docs) {
      final captainId = doc.id;
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(captainId)
          .collection('teams')
          .doc(captainId)
          .get();

      // If team does not exist for the captain, add to available list
      if (!teamDoc.exists) {
        availableCaptains.add(Captain(id: captainId, name: doc['name']));
      }
    }
    return availableCaptains;
  }

  void createTeam(String selectedCaptainName) {
    final teamName = teamNameController.text.trim();
    final phoneNumber = PhoneNumberController.text.trim();
    final captainName = selectedCaptainName.trim();
    final email = emailController.text.trim();
    final tagLine = tagLineController.text.trim();
    final clubName = clubNameController.text.trim();

    List<String> emptyFields = [];
    if (teamName.isEmpty) emptyFields.add('Team Name');
    if (phoneNumber.isEmpty) emptyFields.add('Phone Number');
    if (captainName.isEmpty) emptyFields.add('Captain Name');
    if (email.isEmpty) emptyFields.add('Email');
    if (tagLine.isEmpty) emptyFields.add('Tagline');
    if (clubName.isEmpty) emptyFields.add('Club Name');
    if (_selectedCaptainId == null) emptyFields.add('Captain');
    if (teamLogoUrl == null) emptyFields.add('Image');

    if (emptyFields.isNotEmpty) {
      String errorMessage;
      if (emptyFields.length > 3) {
        errorMessage = 'Please fill in all fields';
      } else if (emptyFields.length == 1) {
        errorMessage = 'Please select the ${emptyFields[0]} field';
      } else {
        errorMessage =
            'Please fill in or select the following fields:\n${emptyFields.join(', ')}';
      }
      _showSnackBar(errorMessage, Colors.red);
      return;
    }

    // if (!_imageSelected) {
    //   _showSnackBar('Please select an image for the team', Colors.red);
    //   return;
    // }

    final teamData = {
      'createdBy': 'admin',
      'teamName': teamName,
      'captainId': _selectedCaptainId,
      'captainname': _selectedCaptainName,
      'phoneNumber': phoneNumber,
      'email': email,
      'tagline': tagLine,
      'clubName': clubName,
      'logo': teamLogoUrl,
    };

    FirebaseFirestore.instance
        .collection('teams')
        .doc(_selectedCaptainId)
        .collection('teams')
        .doc(_selectedCaptainId)
        .set(teamData)
        .then((value) {
      print('Team added successfully.');
      _showSnackBar('Team created successfully', Colors.green);
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to add team: $error');
      _showSnackBar('Failed to create team', Colors.red);
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
        height: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Create Team',
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
                          'Team Image',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(20)),
                          child: GestureDetector(
                              onTap: _pickImage,
                              child: _imageData != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                          child: Text('Image Picked',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                          child: Text('Pick Image',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Club Name',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: clubNameController,
                          decoration: InputDecoration(
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
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Team Name',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: teamNameController,
                          decoration: InputDecoration(
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
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Select Captain',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: FutureBuilder<List<Captain>>(
                          // Fetch captains without teams
                          future: _fetchCaptainsWithoutTeams(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                    color: Colors.deepPurpleAccent),
                              );
                            }

                            var captains = snapshot.data!;

                            return DropdownButtonHideUnderline(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Color(
                                      0xffEEEEEE), // the background color of the dropdown items
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color(
                                        0xffEEEEEE), // border color of the dropdown
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  isExpanded:
                                      true, // makes the dropdown expanded
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors
                                          .black), // the dropdown arrow icon
                                  value: _selectedCaptainId,
                                  hint: Text("Select a captain"),
                                  style: TextStyle(
                                      color: Colors
                                          .black), // style of the dropdown items
                                  items: captains.map((Captain captain) {
                                    return DropdownMenuItem<String>(
                                      value: captain.id,
                                      child: Text(captain.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCaptainId = value;
                                      _selectedCaptainName = captains
                                          .firstWhere(
                                              (captain) => captain.id == value)
                                          .name;
                                      print(
                                          "Selected captain ID: $_selectedCaptainId");
                                      print(
                                          "Selected captain Name: $_selectedCaptainName");
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Phone No',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: PhoneNumberController,
                          decoration: InputDecoration(
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
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Email',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
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
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Team Tagline',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: tagLineController,
                          decoration: InputDecoration(
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
                    createTeam(_selectedCaptainName.toString());
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

// list of teams displaying on the screen
class TeamsList extends StatefulWidget {
  @override
  _TeamsListState createState() => _TeamsListState();
}

class _TeamsListState extends State<TeamsList> {
  // Assuming you're inside a stateful widget:

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _teamName, _phoneNo, _tagLine, _email, _clubName;
  String? _selectedCaptainId;
  String? _selectedCaptainName;

  void _showUpdateDialog(Map<String, dynamic> teamData, String teamId) {
    _selectedCaptainId = teamData['captainId'];
    _selectedCaptainName = teamData['captainname'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Team Data", style: TextStyle(fontFamily: 'karla')),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildFormFields(teamData),
            ),
          ),
          actions: _buildDialogActions(teamId, teamData),
        );
      },
    );
  }

  Future<void> _deleteTeamWithConfirmation(
      int teamIndex, List<DocumentSnapshot> teams) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this team?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      String teamId = teams[teamIndex].id;

      try {
        // Delete from teams collection
        await teams[teamIndex].reference.delete();
      } catch (error) {
        print('Failed to delete from teams collection: $error');
        _showSnackBar('Failed to delete team', Colors.red);
        return;
      }

      try {
        // Delete from requestToJoin collection
        QuerySnapshot requestToJoinSnapshot = await FirebaseFirestore.instance
            .collection('requestToJoin')
            .where('teamId', isEqualTo: teamId)
            .get();

        for (DocumentSnapshot doc in requestToJoinSnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (error) {
        print('Failed to delete from requestToJoin collection: $error');
        _showSnackBar('Failed to delete team join requests', Colors.red);
        return;
      }

      // Delete matches from matchSchedule collection based on events
      try {
        // Fetch all document IDs from the 'events' collection
        QuerySnapshot eventsSnapshot =
            await FirebaseFirestore.instance.collection('events').get();
        List<String> eventIds =
            eventsSnapshot.docs.map((doc) => doc.id).toList();
        print(eventIds);

        for (String eventId in eventIds) {
          // Use the event ID to fetch the specific document from the matchSchedule collection
          DocumentReference matchScheduleDocRef = FirebaseFirestore.instance
              .collection('matchSchedule')
              .doc(eventId);

          // Check the 'matches' subcollection of the fetched document
          QuerySnapshot matchesSnapshot = await matchScheduleDocRef
              .collection('matches')
              .where('team1Id', isEqualTo: teamId)
              .get();

          for (DocumentSnapshot matchDoc in matchesSnapshot.docs) {
            await matchDoc.reference.delete();
          }

          matchesSnapshot = await matchScheduleDocRef
              .collection('matches')
              .where('team2Id', isEqualTo: teamId)
              .get();

          for (DocumentSnapshot matchDoc in matchesSnapshot.docs) {
            await matchDoc.reference.delete();
          }
        }
      } catch (error) {
        print('Failed to delete matches based on events: $error');
        _showSnackBar('Failed to delete matches based on events', Colors.red);
        return;
      }

      _showSnackBar('Team deleted successfully', Colors.red);
    }
  }

  // Future<void> _deleteTeamWithConfirmation(
  //     int teamIndex, List<DocumentSnapshot> teams) async {
  //   bool confirmDelete = await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Confirm Delete'),
  //         content: Text('Are you sure you want to delete this team?'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(true); // Confirm deletion
  //             },
  //             child: Text('Delete'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(false); // Cancel deletion
  //             },
  //             child: Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (confirmDelete == true) {
  //     try {
  //       // Delete from teams collection
  //       await teams[teamIndex].reference.delete();

  //       // Delete from requestToJoin collection
  //       QuerySnapshot requestToJoinSnapshot = await FirebaseFirestore.instance
  //           .collection('requestToJoin')
  //           .where('teamId', isEqualTo: teams[teamIndex].id)
  //           .get();

  //       for (DocumentSnapshot doc in requestToJoinSnapshot.docs) {
  //         await doc.reference.delete();
  //       }

  //       QuerySnapshot matchScheduleSnapshot =
  //           await FirebaseFirestore.instance.collection('matchSchedule').get();

  //       for (DocumentSnapshot tournamentDoc in matchScheduleSnapshot.docs) {
  //         final tournamentId = tournamentDoc.id;
  //         final matchesRef = tournamentDoc.reference.collection('matches');

  //         QuerySnapshot matchesSnapshot = await matchesRef.get();

  //         for (DocumentSnapshot matchDoc in matchesSnapshot.docs) {
  //           final matchData = matchDoc.data() as Map<String, dynamic>;
  //           final team1Id = matchData['team1Id'];
  //           final team2Id = matchData['team2Id'];

  //           if (team1Id == teams[teamIndex].id ||
  //               team2Id == teams[teamIndex].id) {
  //             print(
  //                 'Deleting match document with team1Id: $team1Id and team2Id: $team2Id');
  //             await matchDoc.reference.delete(); // Delete the match document
  //             print('Deleted match document in tournament $tournamentId');
  //           }
  //         }
  //       }

  //       _showSnackBar('Team and matches deleted successfully', Colors.red);
  //     } catch (error) {
  //       print('Failed to delete team: $error');
  //       _showSnackBar('Failed to delete team', Colors.red);
  //     }
  //   }
  // }
  Future<void> fetchAndPrintMatchSchedules() async {
    try {
      CollectionReference matchSchedules =
          FirebaseFirestore.instance.collection('events');
      QuerySnapshot querySnapshot = await matchSchedules.get();

      if (querySnapshot.docs.isEmpty) {
        print("No documents found in matchSchedule.");
      } else {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          print("Document ID: ${doc.id}");
          print(doc.data()); // This will print the data of each document
        }
      }
    } catch (error) {
      print("Error fetching documents: $error");
    }
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

  List<Widget> _buildFormFields(Map<String, dynamic> teamData) {
    return [
      _buildTextField(
          'team name', teamData['teamName'], (value) => _teamName = value),
      SizedBox(height: 10),
      _buildCaptainDropdown(teamData['captainId']),
      SizedBox(height: 10),
      _buildTextField(
          'phone number', teamData['phoneNumber'], (value) => _phoneNo = value),
      SizedBox(height: 10),
      _buildTextField(
          'tagline', teamData['tagline'], (value) => _tagLine = value),
      SizedBox(height: 10),
      _buildTextField('email', teamData['email'], (value) => _email = value),
      // SizedBox(height: 10),
      // _buildTextField(
      //     'club name', teamData['clubName'], (value) => _clubName = value),
    ];
  }

  Widget _buildTextField(
      String hint, String? initialValue, Function(String?) onSave) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Color(0xffEEEEEE),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 0.5, color: Color(0xffEEEEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffEEEEEE)),
        ),
      ),
      onSaved: onSave,
    );
  }

  Future<List<Captain>> _fetchCaptainsWithoutTeams(
      String currentCaptainId) async {
    List<Captain> availableCaptains = [];
    QuerySnapshot captainsSnapshot =
        await FirebaseFirestore.instance.collection('captains').get();

    for (var doc in captainsSnapshot.docs) {
      final captainId = doc.id;
      // If the captain is the current one being edited, don't exclude it
      if (captainId == currentCaptainId) {
        availableCaptains.add(Captain(id: captainId, name: doc['name']));
        continue;
      }

      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(captainId)
          .collection('teams')
          .doc(captainId)
          .get();

      if (!teamDoc.exists) {
        availableCaptains.add(Captain(id: captainId, name: doc['name']));
      }
    }

    return availableCaptains;
  }

  Widget _buildCaptainDropdown(String currentCaptainId) {
    final _selectedCaptainIdNotifier = ValueNotifier<String?>(currentCaptainId);

    return FutureBuilder<List<Captain>>(
      future: _fetchCaptainsWithoutTeams(currentCaptainId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No available captains");
        }

        var captains = snapshot.data!;

        return ValueListenableBuilder<String?>(
            valueListenable: _selectedCaptainIdNotifier,
            builder: (context, selectedCaptainId, child) {
              return DropdownButtonHideUnderline(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xffEEEEEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xffEEEEEE), width: 1),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    value:
                        selectedCaptainId, // Display the current captain's ID
                    hint: Text("Select a captain"),
                    items: captains.map((Captain captain) {
                      return DropdownMenuItem<String>(
                        value: captain.id,
                        child: Text(captain.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        print("Dropdown value changed to: $value");
                        _selectedCaptainIdNotifier.value =
                            value; // Update the selected captain's ID
                        _selectedCaptainId =
                            value; // Assuming this is a class-level variable
                        _selectedCaptainName = captains
                            .firstWhere((captain) => captain.id == value)
                            .name;
                      }
                    },
                  ),
                ),
              );
            });
      },
    );
  }

  List<Widget> _buildDialogActions(
      String teamId, Map<String, dynamic> teamData) {
    return [
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Color(0xff6858FE)),
        ),
        child: Text("Cancel"),
        onPressed: () => Navigator.of(context).pop(),
      ),
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Color(0xff6858FE)),
        ),
        child: Text("Update"),
        onPressed: () {
          _updateFirestore(teamId, teamData);
        },
      ),
    ];
  }

  void _updateFirestore(
      String oldCaptainId, Map<String, dynamic> previousData) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Merge the previous data with the new changes
      Map<String, dynamic> dataToUpdate = {
        ...previousData, // copy all the old data
        'teamName': _teamName,
        'captainId': _selectedCaptainId,
        'captainname': _selectedCaptainName,
        'phoneNumber': _phoneNo,
        'tagline': _tagLine,
        'email': _email,
        // 'clubName': _clubName,
      };

      // If the selected captain has changed
      if (_selectedCaptainId != oldCaptainId) {
        // Delete the team data with the old captain's ID
        FirebaseFirestore.instance
            .collection('teams')
            .doc(oldCaptainId)
            .collection('teams')
            .doc(oldCaptainId)
            .delete();

        // Add the team data with the new captain's ID (or overwrite if it already exists)
        FirebaseFirestore.instance
            .collection('teams')
            .doc(_selectedCaptainId)
            .collection('teams')
            .doc(_selectedCaptainId)
            .set(dataToUpdate);
      } else {
        // If the captain has not changed, just update the existing data
        FirebaseFirestore.instance
            .collection('teams')
            .doc(_selectedCaptainId)
            .collection('teams')
            .doc(_selectedCaptainId)
            .update(dataToUpdate);
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Team Updated Successfully',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.yellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Stream<List<QueryDocumentSnapshot>> fetchAllTeams() {
    return FirebaseFirestore.instance
        .collection('captains')
        .snapshots()
        .switchMap((captainSnapshot) {
      List<Stream<List<QueryDocumentSnapshot>>> streams = [];

      for (var doc in captainSnapshot.docs) {
        var stream = FirebaseFirestore.instance
            .collection('teams')
            .doc(doc.id)
            .collection('teams')
            .snapshots()
            .map((snapshot) => snapshot.docs);

        streams.add(stream);
      }

      return Rx.combineLatestList(streams).map((listOfLists) {
        return listOfLists.expand((list) => list).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: fetchAllTeams(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.deepPurpleAccent,
          ));
        }

        final teams = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            childAspectRatio: 0.9,
          ),
          itemCount: teams.length,
          itemBuilder: (context, teamIndex) {
            final teamData = teams[teamIndex].data() as Map<String, dynamic>;
            final teamLogo = teamData['logo'];
            final teamId = teamData['captainId'];

            return Card(
              color: Color(0xffF3F2FF),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                          fit: BoxFit.cover, image: NetworkImage('$teamLogo')),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(teamData['teamName'],
                      style: TextStyle(
                          fontFamily: 'karla',
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(teamData['captainname'],
                      style: TextStyle(fontFamily: 'karla', fontSize: 16)),
                  SizedBox(height: 10),
                  Text(teamData['tagline'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'karla', fontSize: 16)),
                  // SizedBox(height: 10),
                  // Text(teamData['clubName'],
                  //     style: TextStyle(
                  //         fontFamily: 'karla',
                  //         fontSize: 18,
                  //         fontWeight: FontWeight.w500,
                  //         color: Color(0xffFFA626))),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Implement your edit logic here
                          _showUpdateDialog(teamData, teamId);
                        },
                        child: Text("Edit",
                            style: TextStyle(
                                color: Color(0xff6858FE), fontSize: 18)),
                      ),
                      TextButton(
                        onPressed: () async {
                          // This will delete the selected team
                          // await FirebaseFirestore.instance
                          //     .doc(teams[teamIndex].reference.path)
                          //     .delete();

                          _deleteTeamWithConfirmation(teamIndex, teams);

                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text(
                          //       'Team Deleted Successfully',
                          //       style: TextStyle(color: Colors.white),
                          //     ),
                          //     backgroundColor: Colors.red,
                          //     behavior: SnackBarBehavior.floating,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //   ),
                          // );
                        },
                        child: Text("Delete",
                            style: TextStyle(
                                color: Color(0xff6858FE), fontSize: 18)),
                      )
                    ],
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

// Stream<List<QueryDocumentSnapshot>> fetchAllTeams() {
//   return FirebaseFirestore.instance
//       .collectionGroup('teams')
//       .snapshots()
//       .map((snapshot) {
//     return snapshot
//         .docs; // Convert QuerySnapshot to List<QueryDocumentSnapshot>
//   });
// }

// Stream<List<QueryDocumentSnapshot>> fetchAllTeams() {
//   return FirebaseFirestore.instance
//       .collection('captains')
//       .snapshots()
//       .switchMap((captainsSnapshot) {
//     List<Stream<List<QueryDocumentSnapshot>>> streams = [];

//     for (var doc in captainsSnapshot.docs) {
//       var stream = FirebaseFirestore.instance
//           .collection('teams')
//           .doc(doc.id)
//           .collection('teams')
//           .where('createdBy', isEqualTo: 'admin')
//           .snapshots()
//           .map((snapshot) => snapshot.docs);

//       streams.add(stream);
//     }

//     return Rx.combineLatestList(streams).map((listOfLists) {
//       return listOfLists.expand((list) => list).toList();
//     });
//   });
// }

// final _formKey = GlobalKey<FormState>();
// String? _teamName, _clubName, _capName, _phoneNo, _tagLine, _email;

// String? _selectedCaptainId;
// String? _selectedCaptainName;

// void _showEditDialog(BuildContext context, DocumentSnapshot team) {
//   var teamData = team.data() as Map<String, dynamic>;

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text(
//           "Edit Team Data",
//           style: TextStyle(
//             fontFamily: 'karla',
//           ),
//         ),
//         content: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextFormField(
//                 initialValue: teamData['teamName'],
//                 decoration: InputDecoration(
//                   hintText: 'team name',
//                   filled: true,
//                   fillColor: Color(0xffEEEEEE),
//                   border: OutlineInputBorder(),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 0.5,
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                 ),
//                 onSaved: (value) => _teamName = value,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('captains')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData)
//                     return Center(
//                         child: CircularProgressIndicator(
//                       color: Colors.deepPurpleAccent,
//                     ));

//                   var captains = snapshot.data!.docs.map((doc) {
//                     return Captain(id: doc.id, name: doc['name']);
//                   }).toList();

//                   return DropdownButtonHideUnderline(
//                     child: Container(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Color(
//                             0xffEEEEEE), // the background color of the dropdown items
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: Color(
//                               0xffEEEEEE), // border color of the dropdown
//                           width: 1,
//                         ),
//                       ),
//                       child: DropdownButton<String>(
//                         isExpanded: true, // makes the dropdown expanded
//                         icon: Icon(Icons.arrow_drop_down,
//                             color: Colors.black), // the dropdown arrow icon
//                         value: _selectedCaptainId,
//                         hint: Text("Select a captain"),
//                         style: TextStyle(
//                             color:
//                                 Colors.black), // style of the dropdown items
//                         items: captains.map((Captain captain) {
//                           return DropdownMenuItem<String>(
//                             value: captain.id,
//                             child: Text(captain.name),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedCaptainId = value;
//                             _selectedCaptainName = captains
//                                 .firstWhere((captain) => captain.id == value)
//                                 .name;
//                             print("Selected captain ID: $_selectedCaptainId");
//                             print(
//                                 "Selected captain Name: $_selectedCaptainName");
//                           });
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                 initialValue: teamData['phoneNumber'],
//                 decoration: InputDecoration(
//                   hintText: 'phone number',
//                   filled: true,
//                   fillColor: Color(0xffEEEEEE),
//                   border: OutlineInputBorder(),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 0.5,
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                 ),
//                 onSaved: (value) => _phoneNo = value,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                 initialValue: teamData['tagline'],
//                 decoration: InputDecoration(
//                   hintText: 'tagline',
//                   filled: true,
//                   fillColor: Color(0xffEEEEEE),
//                   border: OutlineInputBorder(),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 0.5,
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                 ),
//                 onSaved: (value) => _tagLine = value,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                 initialValue: teamData['email'],
//                 decoration: InputDecoration(
//                   hintText: 'email',
//                   filled: true,
//                   fillColor: Color(0xffEEEEEE),
//                   border: OutlineInputBorder(),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 0.5,
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                 ),
//                 onSaved: (value) => _email = value,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                 initialValue: teamData['clubName'],
//                 decoration: InputDecoration(
//                   hintText: 'club name',
//                   filled: true,
//                   fillColor: Color(0xffEEEEEE),
//                   border: OutlineInputBorder(),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       width: 0.5,
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Color(0xffEEEEEE),
//                     ),
//                   ),
//                 ),
//                 onSaved: (value) => _clubName = value,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           ElevatedButton(
//             style: ButtonStyle(
//                 backgroundColor: MaterialStatePropertyAll(Color(0xff6858FE))),
//             child: Text("Cancel"),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           ElevatedButton(
//             style: ButtonStyle(
//                 backgroundColor: MaterialStatePropertyAll(Color(0xff6858FE))),
//             child: Text("Update"),
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 _formKey.currentState!.save();
//                 // TODO: Here, update the Firestore document with the new data
//                 FirebaseFirestore.instance
//                     .collection('teams')
//                     .doc(team.id)
//                     .update({
//                   'teamName': _teamName,
//                   'captainname': _capName,
//                   'phoneNumber': _phoneNo,
//                   "tagline": _tagLine,
//                   'email': _email,
//                   'clubName': _clubName,
//                 });
//                 Navigator.of(context).pop();
//               }
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<List<QueryDocumentSnapshot>> fetchAllTeams() async {
//   final captainsSnapshot =
//       await FirebaseFirestore.instance.collection('captains').get();
//   print(
//       "Number of captains fetched: ${captainsSnapshot.docs.length}"); // Debug print

//   List<QueryDocumentSnapshot> allTeams = [];

//   for (var doc in captainsSnapshot.docs) {
//     final teamsSnapshot = await FirebaseFirestore.instance
//         .collection('teams')
//         .doc(doc.id)
//         .collection('teams')
//         .where('createdBy', isEqualTo: 'admin')
//         .get();

//     print(
//         "Number of teams for captain ${doc.id}: ${teamsSnapshot.docs.length}"); // Debug print
//     allTeams.addAll(teamsSnapshot.docs);
//   }

//   print("Total teams fetched: ${allTeams.length}"); // Debug print
//   return allTeams;
// }

// TextFormField(
//   initialValue: teamData['captainname'],
//   decoration: InputDecoration(
//     hintText: 'captain name',
//     filled: true,
//     fillColor: Color(0xffEEEEEE),
//     border: OutlineInputBorder(),
//     enabledBorder: OutlineInputBorder(
//       borderSide: BorderSide(
//         width: 0.5,
//         color: Color(0xffEEEEEE),
//       ),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(
//         color: Color(0xffEEEEEE),
//       ),
//     ),
//   ),
//   onSaved: (value) => _capName = value,
// ),

// StreamBuilder<QuerySnapshot>(
//   stream: FirebaseFirestore.instance
//       .collection('teams')
//       .where('createdBy', isEqualTo: 'admin')
//       .snapshots(),
//   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//     if (snapshot.hasError) return Text('Something went wrong');
//     if (snapshot.connectionState == ConnectionState.waiting)
//       return Text("Loading...");

//     final teams = snapshot.data!.docs;

//     return SingleChildScrollView(
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           mainAxisSpacing: 4.0,
//           crossAxisSpacing: 4.0,
//           childAspectRatio: 0.9,
//         ),
//         itemCount: teams.length,
//         itemBuilder: (context, index) {
//           final teamData = teams[index].data() as Map<String, dynamic>;
//           final teamLogo = teamData['logo'];

//           return Card(
//             color: Color(0xffF3F2FF),
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10)),

//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 70,
//                   height: 70,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Color(0xffFFA626), width: 2),
//                     image: DecorationImage(
//                         fit: BoxFit.cover,
//                         image: NetworkImage('$teamLogo')),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(teamData['teamName'],
//                     style: TextStyle(
//                         fontFamily: 'karla',
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold)),
//                 SizedBox(height: 10),
//                 Text(teamData['captainname'],
//                     style: TextStyle(
//                       fontFamily: 'karla',
//                       fontSize: 16,
//                     )),
//                 SizedBox(height: 10),
//                 Text(teamData['tagline'],
//                 style: TextStyle(
//                   fontFamily: 'karla',
//                   fontSize: 16,
//                 )
//                 ),
//                 SizedBox(height: 10),
//                 Text(teamData['clubName'],
//                     style: TextStyle(
//                         fontFamily: 'karla',
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xffFFA626))),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         _showEditDialog(context, teams[index]);
//                       },
//                       child: Text("Edit",
//                           style: TextStyle(
//                             color: Color(0xff6858FE),
//                             fontSize: 18,
//                           )),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         FirebaseFirestore.instance
//                             .collection('adminTeamsCreation')
//                             .doc(teams[index].id)
//                             .delete();
//                       },
//                       child: Text(
//                         "Delete",
//                         style: TextStyle(
//                           color: Color(0xff6858FE),
//                           fontSize: 18,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   },
// );
