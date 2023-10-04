import 'package:admin_panel/widgets/referees/addNewRef.dart';
import 'package:admin_panel/widgets/referees/editRefDialogue.dart';
import 'package:admin_panel/widgets/referees/refPreview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Referees {
  final String? id; // Changed from Referees? to String
  final String name;
  final String email;
  final String age;
  final String address;
  final String experience; // Typo fixed in the variable name
  final String specialization; // Typo fixed in the variable name

  Referees({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.address,
    required this.experience,
    required this.specialization,
  });
}

class RefereesScreen extends StatefulWidget {
  @override
  _RefereesScreenState createState() => _RefereesScreenState();
}

class _RefereesScreenState extends State<RefereesScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Referees',
                      style: TextStyle(
                        fontFamily: 'karla',
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Color(0xff2D2D2D),
                      ),
                    ),
                    Container(
                      width: 200,
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
                          _openAddNewRefPage(context);
                        },
                        child: Text(
                          'ADD NEW REFEREE',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'karla',
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('referees').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error fetching referees');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No Referees available'));
                  }

                  List<Referees> refereesList = snapshot.data!.docs.map((doc) {
                    // var refData = doc.data() as Map<Referees, dynamic>;
                    var refData = doc.data() as Map<String, dynamic>;

                    return Referees(
                      id: doc.id,
                      name: refData['name'] ?? '',
                      email: refData['email'] ?? '',
                      age: refData['age'] ?? '',
                      address: refData['address'] ?? '',
                      experience: refData['experience'] ?? '',
                      specialization: refData['specialization'] ?? '',
                    );
                  }).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: refereesList.length,
                    itemBuilder: (context, index) {
                      return _buildRefereeCard(refereesList[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefereeCard(Referees referee) {
    print(referee);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Color(0xffFFF9F0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Icon(
              Icons.person,
              size: 35,
              color: Color(0xffFFA626),
            ),
            SizedBox(height: 10),
            Text(
              referee.name,
              style: TextStyle(
                color: Color(0xffFFA626),
                fontSize: 20,
                fontFamily: 'karla',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              referee.email,
              style: TextStyle(
                  fontFamily: 'karla', fontSize: 16, color: Color(0xff2D2D2D)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _openRefPreviewPage(context, referee);
                  },
                  child:
                      Text('View', style: TextStyle(color: Color(0xffFFA626))),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    _editReferee(referee);
                  },
                  child:
                      Text('Edit', style: TextStyle(color: Color(0xffFFA626))),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    // _deleteReferee(referee);
                    _showDeleteConfirmationDialog(referee);
                  },
                  child: Text('Delete',
                      style: TextStyle(color: Color(0xffFFA626))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReferee(Referees referee) async {
    try {
      await firestore.collection('referees').doc(referee.id).delete();
      print('referee is deleted!');
    } catch (e) {
      print('Error deleting referee: $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog(Referees referee) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // The user must tap the buttons!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Referee'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this referee?'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.deepPurpleAccent)),
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.deepPurpleAccent)),
              child: Text('Confirm'),
              onPressed: () async {
                // Here you can delete the referee from your database
                await firestore.collection('referees').doc(referee.id).delete();

                Navigator.of(context).pop(); // Close the dialog
                // Optionally, you can show a SnackBar message to notify the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Referee deleted successfully'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editReferee(Referees referee) async {
    Referees? editedReferee = await showDialog<Referees>(
      context: context,
      builder: (BuildContext context) {
        return EditRefereeDialog(referee: referee);
      },
    );

    if (editedReferee != null) {
      print('Edited Referee Name: ${editedReferee.name}');
      print('Edited Referee Email: ${editedReferee.email}');
    }
  }

  void _openAddNewRefPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewRefPage(
          onTournamentCreated: (tournament) {},
        ),
      ),
    );
  }

  void _openRefPreviewPage(BuildContext context, Referees referee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefPreviewPage(tournament: referee),
      ),
    );
  }
}
