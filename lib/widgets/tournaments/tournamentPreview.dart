import 'package:admin_panel/screens/tournament.dart';
import 'package:admin_panel/widgets/matchOrganizingWidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/refrees.dart';
import '../addRef.dart';
import '../deletionReason.dart';
import '../editRefFromTournamentPreview.dart';

final firestore = FirebaseFirestore.instance;

class TournamentPreviewPage extends StatefulWidget {
  final Tournament tournament;
  final String tournamentId;

  TournamentPreviewPage({required this.tournament, required this.tournamentId});

  @override
  State<TournamentPreviewPage> createState() => _TournamentPreviewPageState();
}

class _TournamentPreviewPageState extends State<TournamentPreviewPage> {
  List<Map<String, dynamic>> refereesDetails = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRefereesDetails();
  }

  void _loadRefereesDetails() async {
    setState(() {
      isLoading = true;
    });

    refereesDetails = await _fetchRefereesDetails(widget.tournamentId);

    setState(() {
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchRefereesDetails(
      String tournamentId) async {
    List<Map<String, dynamic>> refereesDetails = [];
    List<String> refereesDocIds = [];
    List<String> nonExistentRefereeIds =
        []; // to keep track of non-existent IDs

    try {
      DocumentSnapshot doc =
          await firestore.collection('events').doc(tournamentId).get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('refereesDocIds')) {
          var rawRefereesDocIds = data['refereesDocIds'];
          print('Raw Referees Doc IDs: $rawRefereesDocIds');

          if (rawRefereesDocIds is List) {
            refereesDocIds = rawRefereesDocIds.cast<String>();
          } else if (rawRefereesDocIds is String) {
            refereesDocIds = rawRefereesDocIds
                .replaceAll('[', '')
                .replaceAll(']', '')
                .split(',')
                .map((s) => s.trim())
                .toList();
          } else {
            print(
                'Unexpected type for refereesDocIds: ${rawRefereesDocIds.runtimeType}');
          }

          print('Processed Referees Doc IDs: $refereesDocIds');

          for (var id in refereesDocIds) {
            DocumentSnapshot refereeDoc =
                await firestore.collection('referees').doc(id).get();
            if (refereeDoc.exists) {
              refereesDetails.add(refereeDoc.data() as Map<String, dynamic>);
              print('Referee Details for ID $id: ${refereeDoc.data()}');
            } else {
              print('No referee found for ID $id');
              nonExistentRefereeIds.add(id);
            }
          }

          // If any non-existent referee IDs were found, update the `events` document
          if (nonExistentRefereeIds.isNotEmpty) {
            refereesDocIds
                .removeWhere((id) => nonExistentRefereeIds.contains(id));

            await firestore
                .collection('events')
                .doc(tournamentId)
                .update({'refereesDocIds': refereesDocIds});
          }
        } else {
          print('No refereesDocIds key found in the document data');
        }
      } else {
        print('Tournament with ID $tournamentId does not exist');
      }
    } catch (e) {
      print('Error fetching referee details: $e');
    }

    return refereesDetails;
  }

  // Future<List<Map<String, dynamic>>> _fetchRefereesDetails(
  //     String tournamentId) async {
  //   List<Map<String, dynamic>> refereesDetails = [];
  //   List<String> refereesDocIds = [];

  //   try {
  //     DocumentSnapshot doc =
  //         await firestore.collection('events').doc(tournamentId).get();

  //     if (doc.exists) {
  //       Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
  //       if (data != null && data.containsKey('refereesDocIds')) {
  //         var rawRefereesDocIds = data['refereesDocIds'];
  //         print('Raw Referees Doc IDs: $rawRefereesDocIds');

  //         if (rawRefereesDocIds is List) {
  //           // Cast each item to a string
  //           refereesDocIds = rawRefereesDocIds.cast<String>();
  //         } else if (rawRefereesDocIds is String) {
  //           // Remove square brackets and split by comma
  //           refereesDocIds = rawRefereesDocIds
  //               .replaceAll('[', '')
  //               .replaceAll(']', '')
  //               .split(',')
  //               .map((s) => s.trim())
  //               .toList();
  //         } else {
  //           print(
  //               'Unexpected type for refereesDocIds: ${rawRefereesDocIds.runtimeType}');
  //         }

  //         print('Processed Referees Doc IDs: $refereesDocIds');

  //         for (var id in refereesDocIds) {
  //           DocumentSnapshot refereeDoc =
  //               await firestore.collection('referees').doc(id).get();
  //           if (refereeDoc.exists) {
  //             refereesDetails.add(refereeDoc.data() as Map<String, dynamic>);
  //             print('Referee Details for ID $id: ${refereeDoc.data()}');
  //           } else {
  //             print('No referee found for ID $id');
  //           }
  //         }
  //       } else {
  //         print('No refereesDocIds key found in the document data');
  //       }
  //     } else {
  //       print('Tournament with ID $tournamentId does not exist');
  //     }
  //   } catch (e) {
  //     print('Error fetching referee details: $e');
  //   }

  //   return refereesDetails;
  // }

// fetching referee details using stream ...
  Stream<List<Map<String, dynamic>>> refereesDetailsStream(
      String tournamentId) {
    return firestore
        .collection('events')
        .doc(tournamentId)
        .snapshots()
        .asyncMap((eventDoc) async {
      if (eventDoc.exists) {
        var eventData = eventDoc.data() as Map<String, dynamic>;
        List<String> refereesDocIds =
            List.from(eventData['refereesDocIds'] ?? []);

        List<Map<String, dynamic>> refereesDetails = [];
        for (var id in refereesDocIds) {
          DocumentSnapshot refereeDoc =
              await firestore.collection('referees').doc(id).get();
          if (refereeDoc.exists) {
            refereesDetails.add(refereeDoc.data() as Map<String, dynamic>);
          }
        }
        return refereesDetails;
      } else {
        return [];
      }
    });
  }

  Future<void> _editReferee(String refDocId) async {
    Map<String, dynamic>? editedRefereeData =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return UpdateRefereeDialog(docId: refDocId);
      },
    );

    if (editedRefereeData != null) {
      final index =
          refereesDetails.indexWhere((referee) => referee['id'] == refDocId);
      if (index != -1) {
        setState(() {
          refereesDetails[index] = editedRefereeData;
        });
      }
    }
    setState(() {});
  }

// to delete referees....
  void _deleteReferee(int index) async {
    print("Starting the delete referee process...");

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to delete this referee?'),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Colors.deepPurpleAccent)),
            onPressed: () {
              print("Delete confirmed.");
              Navigator.pop(context, true);
            },
            child: Text('Yes'),
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Colors.deepPurpleAccent)),
            onPressed: () {
              print("Delete canceled.");
              Navigator.pop(context, false);
            },
            child: Text('No'),
          ),
        ],
      ),
    );

    if (isConfirmed!) {
      try {
        String refereeIdToRemove;

        if (refereesDetails[index].containsKey('id')) {
          refereeIdToRemove = refereesDetails[index]['id'];
          print("Referee ID to remove: $refereeIdToRemove");
        } else {
          print('Referee at index $index does not have an ID.');
          return;
        }

        print("Fetching current list of referee IDs from Firestore...");
        DocumentSnapshot doc =
            await firestore.collection('events').doc(widget.tournamentId).get();

        if (doc.exists) {
          List<String> currentRefereesDocIds = [];

          dynamic rawData = doc['refereesDocIds'];

          if (rawData is String) {
            // Parsing the string into a list
            currentRefereesDocIds =
                rawData.split(',').map((e) => e.trim()).toList();
          } else if (rawData is List) {
            currentRefereesDocIds = List<String>.from(rawData);
          } else {
            print("Unexpected data type for refereesDocIds.");
            return;
          }

          // Ensure the referee ID is present before attempting removal
          if (currentRefereesDocIds.contains(refereeIdToRemove)) {
            currentRefereesDocIds.remove(refereeIdToRemove);

            // Writing the updated list back to Firestore
            print("Writing updated list to Firestore...");
            await firestore
                .collection('events')
                .doc(widget.tournamentId)
                .update({'refereesDocIds': currentRefereesDocIds});
            print("Updated list written to Firestore.");

            // Remove the referee from the local list.
            print("Updating local state...");
            setState(() {
              refereesDetails.removeAt(index);
            });
            print("Local state updated.");

            // Displaying a SnackBar notification to the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Referee deleted successfully!'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else {
            print("Referee ID not found in the Firestore list.");
          }
        } else {
          print("Document does not exist in Firestore.");
        }
      } catch (e) {
        print('Error deleting referee: $e');
        // Optionally, you can display an error snackbar as well
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting referee. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      print("Delete operation was not confirmed.");
    }
  }

  // void _deleteReferee(int index) async {
  //   print("Starting the delete referee process...");

  //   final isConfirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Confirmation'),
  //       content: Text('Are you sure you want to delete this referee?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             print("Delete confirmed.");
  //             Navigator.pop(context, true);
  //           },
  //           child: Text('Yes'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             print("Delete canceled.");
  //             Navigator.pop(context, false);
  //           },
  //           child: Text('No'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (isConfirmed!) {
  //     String refereeIdToRemove;

  //     if (refereesDetails[index].containsKey('id')) {
  //       refereeIdToRemove = refereesDetails[index]['id'];
  //       print("Referee ID to remove: $refereeIdToRemove");
  //     } else {
  //       print('Referee at index $index does not have an ID.');
  //       return;
  //     }

  //     try {
  //       print("Fetching current list of referee IDs from Firestore...");
  //       DocumentSnapshot doc =
  //           await firestore.collection('events').doc(widget.tournamentId).get();

  //       List<String> currentRefereesDocIds = [];
  //       var rawData = doc['refereesDocIds'];

  //       if (rawData is String) {
  //         // Parsing the string into a list
  //         currentRefereesDocIds =
  //             rawData.split(',').map((e) => e.trim()).toList();
  //       } else if (rawData is List) {
  //         currentRefereesDocIds = List<String>.from(rawData);
  //       } else {
  //         print("Unexpected data type for refereesDocIds.");
  //         return;
  //       }

  //       // Manually removing the referee ID
  //       currentRefereesDocIds.remove(refereeIdToRemove);

  //       // Writing the updated list back to Firestore
  //       print("Writing updated list to Firestore...");
  //       await firestore
  //           .collection('events')
  //           .doc(widget.tournamentId)
  //           .update({'refereesDocIds': currentRefereesDocIds});
  //       print("Updated list written to Firestore.");

  //       // Remove the referee from the local list.
  //       print("Updating local state...");
  //       setState(() {
  //         refereesDetails.removeAt(index);
  //       });
  //       print("Local state updated.");
  //     } catch (e) {
  //       print('Error deleting referee: $e');
  //     }
  //   } else {
  //     print("Delete operation was not confirmed.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                        '${widget.tournament.name}',
                        style: TextStyle(
                            fontFamily: 'karla',
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color: Color(0xff2D2D2D)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: 1400,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xffFFF9F0),
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // date
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 26,
                                          color: Color(0xffFFA626),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Date',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'karla',
                                            color: Color(0xffFFA626),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          '${widget.tournament.date}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'karla'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    // teams
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.groups,
                                          size: 26,
                                          color: Color(0xffFFA626),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Teams',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'karla',
                                            color: Color(0xffFFA626),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          '${widget.tournament.teams}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'karla'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    // referees
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.group,
                                          size: 26,
                                          color: Color(0xffFFA626),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Referees',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'karla',
                                            color: Color(0xffFFA626),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          '${widget.tournament.refereeNames?.join(', ') ?? ''}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'karla'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                // venue
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fmd_good_rounded,
                                      size: 36,
                                      color: Color(0xffFFA626),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Venue',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontFamily: 'karla',
                                        color: Color(0xffFFA626),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Text(
                                      '${widget.tournament.venue}',
                                      style: TextStyle(
                                          fontSize: 30, fontFamily: 'karla'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  // participating teams........
                  Container(
                    width: 1400,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffF2F0FF),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Teams Participating',
                                style: TextStyle(
                                    fontFamily: 'karla',
                                    fontSize: 26,
                                    color: Color(0xff6858FE)),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 170,
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.deepPurpleAccent),
                                      ),
                                      onPressed: () {
                                        showAdminTeams(context);
                                      },
                                      child: Text(
                                        'Add New Team',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'karla',
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 150,
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.deepPurpleAccent),
                                      ),
                                      onPressed: () {
                                        showTeamJoinRequests(context);
                                      },
                                      child: Text(
                                        'Requests',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'karla',
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: Row(
                        //     children: [
                        //       StreamBuilder<QuerySnapshot>(
                        //         stream: FirebaseFirestore.instance
                        //             .collection('requestToJoin')
                        //             .where('tournamentId',
                        //                 isEqualTo: widget.tournamentId)
                        //             .where('status', isEqualTo: 'approved')
                        //             .snapshots(),
                        //         builder: (BuildContext context,
                        //             AsyncSnapshot<QuerySnapshot> snapshot) {
                        //           if (snapshot.hasError) {
                        //             return Text('Error: ${snapshot.error}');
                        //           }

                        //           if (snapshot.connectionState ==
                        //               ConnectionState.waiting) {
                        //             return Text('Loading...');
                        //           }

                        //           if (!snapshot.hasData ||
                        //               snapshot.data!.docs.isEmpty) {
                        //             return Text('No accepted teams yet.');
                        //           }

                        //           return ListView.builder(
                        //             shrinkWrap: true,
                        //             scrollDirection: Axis.horizontal,
                        //             itemCount: snapshot.data!.docs.length,
                        //             itemBuilder: (context, index) {
                        //               final requestData =
                        //                   snapshot.data!.docs[index].data()
                        //                       as Map<String, dynamic>?;
                        //               final teamId = requestData?['teamId'];
                        //               final requestDataId =
                        //                   snapshot.data!.docs[index].id;

                        //               return FutureBuilder<QuerySnapshot>(
                        //                 future: FirebaseFirestore.instance
                        //                     .collection('teams')
                        //                     .doc(teamId)
                        //                     .collection('teams')
                        //                     .get(),
                        //                 builder: (BuildContext context,
                        //                     AsyncSnapshot<QuerySnapshot>
                        //                         teamSnapshot) {
                        //                   if (!teamSnapshot.hasData ||
                        //                       teamSnapshot.data!.docs.isEmpty) {
                        //                     return Text(
                        //                         'Error: Team not found.');
                        //                   }

                        //                   final teamData = teamSnapshot
                        //                       .data!.docs.first
                        //                       .data() as Map<String, dynamic>;

                        //                   return Stack(
                        //                     children: [
                        //                       Center(
                        //                         child: Column(
                        //                           mainAxisAlignment:
                        //                               MainAxisAlignment.center,
                        //                           children: [
                        //                             Container(
                        //                               width: 60,
                        //                               height: 60,
                        //                               decoration: BoxDecoration(
                        //                                 borderRadius:
                        //                                     BorderRadius
                        //                                         .circular(10),
                        //                                 border: Border.all(
                        //                                     color: Color(
                        //                                         0xffFFA626),
                        //                                     width: 2),
                        //                                 image: DecorationImage(
                        //                                   fit: BoxFit.cover,
                        //                                   image: NetworkImage(
                        //                                       teamData['logo']),
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                             SizedBox(height: 5),
                        //                             Text(
                        //                               '${teamData['teamName']}'
                        //                                   .toUpperCase(),
                        //                               textAlign:
                        //                                   TextAlign.center,
                        //                               style: TextStyle(
                        //                                   fontFamily: 'karla',
                        //                                   fontSize: 14,
                        //                                   fontWeight:
                        //                                       FontWeight.w600),
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                       Positioned(
                        //                         right: 0,
                        //                         top: 0,
                        //                         child: IconButton(
                        //                           icon: Icon(Icons.close,
                        //                               color: Colors.black),
                        //                           onPressed: () async {
                        //                             final result =
                        //                                 await showDialog<
                        //                                     Map<String,
                        //                                         dynamic>>(
                        //                               context: context,
                        //                               builder: (BuildContext
                        //                                   context) {
                        //                                 return DeleteReasonDialog();
                        //                               },
                        //                             );

                        //                             if (result != null &&
                        //                                 result['confirmed'] ==
                        //                                     true) {
                        //                               // Storing the reason in Firestore
                        //                               await FirebaseFirestore
                        //                                   .instance
                        //                                   .collection(
                        //                                       'deletionReasons')
                        //                                   .add({
                        //                                 'teamId': teamId,
                        //                                 'reason':
                        //                                     result['reason'],
                        //                                 'timestamp':
                        //                                     DateTime.now(),
                        //                               });

                        //                               // Deleting the team request after storing the reason
                        //                               await FirebaseFirestore
                        //                                   .instance
                        //                                   .collection(
                        //                                       'requestToJoin')
                        //                                   .doc(requestDataId)
                        //                                   .delete();
                        //                             }
                        //                           },
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   );
                        //                 },
                        //               );
                        //             },
                        //           );
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // )
                        Expanded(
                          child: Row(
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('requestToJoin')
                                    .where('tournamentId',
                                        isEqualTo: widget.tournamentId)
                                    .where('status', isEqualTo: 'approved')
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text('Loading...');
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Text('No accepted teams yet.');
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      final requestData =
                                          snapshot.data!.docs[index].data()
                                              as Map<String, dynamic>?;
                                      final teamId = requestData?['teamId'];
                                      final requestDataId =
                                          snapshot.data!.docs[index].id;

                                      return FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('teams')
                                            .doc(teamId)
                                            .collection('teams')
                                            .get(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                teamSnapshot) {
                                          // Check if the snapshot is still loading
                                          if (teamSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator(
                                              color: Colors.deepPurpleAccent,
                                            )); // or some other loading indicator
                                          }

                                          // If there's an actual error in fetching the team
                                          if (teamSnapshot.hasError) {
                                            return Text(
                                                'Error: ${teamSnapshot.error}');
                                          }

                                          // If the team is not found (even after loading)
                                          if (!teamSnapshot.hasData ||
                                              teamSnapshot.data!.docs.isEmpty) {
                                            return Text('No teams yet.');
                                          }

                                          final teamData = teamSnapshot
                                              .data!.docs.first
                                              .data() as Map<String, dynamic>;

                                          return Stack(
                                            children: [
                                              Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xffFFA626),
                                                              width: 2),
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(
                                                                teamData[
                                                                    'logo']),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        '${teamData['teamName']}'
                                                            .toUpperCase(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily: 'karla',
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                child: IconButton(
                                                  icon: Icon(Icons.remove,
                                                      color: Colors.black),
                                                  onPressed: () async {
                                                    final result =
                                                        await showDialog<
                                                            Map<String,
                                                                dynamic>>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return DeleteReasonDialog();
                                                      },
                                                    );

                                                    if (result != null &&
                                                        result['confirmed'] ==
                                                            true) {
                                                      // Storing the reason in Firestore
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'deletionReasons')
                                                          .add({
                                                        'teamId': teamId,
                                                        'reason':
                                                            result['reason'],
                                                        'timestamp':
                                                            DateTime.now(),
                                                      });

                                                      // Deleting the team request after storing the reason
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'requestToJoin')
                                                          .doc(requestDataId)
                                                          .delete();
                                                      // Delete matches from matchSchedule collection based on events
                                                      try {
                                                        // Fetch all document IDs from the 'events' collection
                                                        QuerySnapshot
                                                            eventsSnapshot =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'events')
                                                                .get();
                                                        List<String> eventIds =
                                                            eventsSnapshot.docs
                                                                .map((doc) =>
                                                                    doc.id)
                                                                .toList();
                                                        print(eventIds);

                                                        for (String eventId
                                                            in eventIds) {
                                                          // Use the event ID to fetch the specific document from the matchSchedule collection
                                                          DocumentReference
                                                              matchScheduleDocRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'matchSchedule')
                                                                  .doc(eventId);

                                                          // Check the 'matches' subcollection of the fetched document
                                                          QuerySnapshot
                                                              matchesSnapshot =
                                                              await matchScheduleDocRef
                                                                  .collection(
                                                                      'matches')
                                                                  .where(
                                                                      'team1Id',
                                                                      isEqualTo:
                                                                          teamId)
                                                                  .get();

                                                          for (DocumentSnapshot matchDoc
                                                              in matchesSnapshot
                                                                  .docs) {
                                                            await matchDoc
                                                                .reference
                                                                .delete();
                                                          }

                                                          matchesSnapshot =
                                                              await matchScheduleDocRef
                                                                  .collection(
                                                                      'matches')
                                                                  .where(
                                                                      'team2Id',
                                                                      isEqualTo:
                                                                          teamId)
                                                                  .get();

                                                          for (DocumentSnapshot matchDoc
                                                              in matchesSnapshot
                                                                  .docs) {
                                                            await matchDoc
                                                                .reference
                                                                .delete();
                                                          }
                                                        }
                                                      } catch (error) {
                                                        print(
                                                            'Failed to delete matches based on events: $error');
                                                        return;
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        )

                        // Expanded(
                        //   child: Row(
                        //     children: [
                        //       StreamBuilder<QuerySnapshot>(
                        //         stream: FirebaseFirestore.instance
                        //             .collection('requestToJoin')
                        //             .where('tournamentId',
                        //                 isEqualTo: widget.tournamentId)
                        //             .where('status', isEqualTo: 'approved')
                        //             .snapshots(),
                        //         builder: (BuildContext context,
                        //             AsyncSnapshot<QuerySnapshot> snapshot) {
                        //           if (snapshot.hasError) {
                        //             return Text('Error: ${snapshot.error}');
                        //           }

                        //           if (snapshot.connectionState ==
                        //               ConnectionState.waiting) {
                        //             return Text('Loading...');
                        //           }

                        //           if (!snapshot.hasData ||
                        //               snapshot.data!.docs.isEmpty) {
                        //             return Text('No accepted teams yet.');
                        //           }

                        //           return ListView.builder(
                        //             shrinkWrap: true,
                        //             scrollDirection: Axis.horizontal,
                        //             itemCount: snapshot.data!.docs.length,
                        //             itemBuilder: (context, index) {
                        //               final requestData =
                        //                   snapshot.data!.docs[index].data()
                        //                       as Map<String, dynamic>?;
                        //               final teamId = requestData?['teamId'];
                        //               final requestDataId = snapshot
                        //                   .data!
                        //                   .docs[index]
                        //                   .id; // Fetch the ID of the requestToJoin document

                        //               if (teamId != null) {
                        //                 return FutureBuilder<QuerySnapshot>(
                        //                   future: FirebaseFirestore.instance
                        //                       .collection('teams')
                        //                       .doc(teamId)
                        //                       .collection('teams')
                        //                       .get(),
                        //                   builder: (BuildContext context,
                        //                       AsyncSnapshot<QuerySnapshot>
                        //                           snapshot) {
                        //                     if (snapshot.connectionState ==
                        //                         ConnectionState.waiting) {
                        //                       return Text('Loading team...');
                        //                     }

                        //                     if (!snapshot.hasData ||
                        //                         snapshot.data!.docs.isEmpty) {
                        //                       return Text(
                        //                           'Error: Team not found.');
                        //                     }

                        //                     final teamData =
                        //                         snapshot.data!.docs.first.data()
                        //                             as Map<String, dynamic>?;
                        //                     if (teamData == null) {
                        //                       return Text(
                        //                           'Error: Team not found.');
                        //                     }

                        //                     final teamName =
                        //                         teamData['teamName'];
                        //                     final logo = teamData['logo'];

                        //                     return Stack(
                        //                       alignment: Alignment.topRight,
                        //                       children: [
                        //                         Center(
                        //                           child: Padding(
                        //                             padding: const EdgeInsets
                        //                                     .symmetric(
                        //                                 horizontal:
                        //                                     10.0), // adjust as needed
                        //                             child: Column(
                        //                               mainAxisAlignment:
                        //                                   MainAxisAlignment
                        //                                       .center,
                        //                               children: [
                        //                                 Container(
                        //                                   width: 60,
                        //                                   height: 60,
                        //                                   decoration:
                        //                                       BoxDecoration(
                        //                                     borderRadius:
                        //                                         BorderRadius
                        //                                             .circular(
                        //                                                 10),
                        //                                     border: Border.all(
                        //                                         color: Color(
                        //                                             0xffFFA626),
                        //                                         width: 2),
                        //                                     image:
                        //                                         DecorationImage(
                        //                                       fit: BoxFit.cover,
                        //                                       image:
                        //                                           NetworkImage(
                        //                                               logo),
                        //                                     ),
                        //                                   ),
                        //                                 ),
                        //                                 SizedBox(height: 5),
                        //                                 Text(
                        //                                   '$teamName'
                        //                                       .toUpperCase(),
                        //                                   textAlign:
                        //                                       TextAlign.center,
                        //                                   style: TextStyle(
                        //                                       fontFamily:
                        //                                           'karla',
                        //                                       fontSize: 14,
                        //                                       fontWeight:
                        //                                           FontWeight
                        //                                               .w600),
                        //                                 ),
                        //                               ],
                        //                             ),
                        //                           ),
                        //                         ),
                        //                         Positioned(
                        //                           right: 0,
                        //                           child: IconButton(
                        //                             icon: Icon(Icons.close,
                        //                                 color: Colors.red),
                        //                             onPressed: () async {
                        //                               final confirm =
                        //                                   await showDialog(
                        //                                 context: context,
                        //                                 builder: (BuildContext
                        //                                     context) {
                        //                                   return AlertDialog(
                        //                                     title: Text(
                        //                                         "Confirm Delete"),
                        //                                     content: Text(
                        //                                         "Are you sure you want to delete this request?"),
                        //                                     actions: <Widget>[
                        //                                       TextButton(
                        //                                         child: Text(
                        //                                             "Cancel"),
                        //                                         onPressed: () {
                        //                                           Navigator.of(
                        //                                                   context)
                        //                                               .pop(
                        //                                                   false);
                        //                                         },
                        //                                       ),
                        //                                       TextButton(
                        //                                         child: Text(
                        //                                             "Delete"),
                        //                                         onPressed: () {
                        //                                           Navigator.of(
                        //                                                   context)
                        //                                               .pop(
                        //                                                   true);
                        //                                         },
                        //                                       ),
                        //                                     ],
                        //                                   );
                        //                                 },
                        //                               );

                        //                               if (confirm) {
                        //                                 FirebaseFirestore
                        //                                     .instance
                        //                                     .collection(
                        //                                         'requestToJoin')
                        //                                     .doc(requestDataId)
                        //                                     .delete();
                        //                               }
                        //                             },
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     );
                        //                   },
                        //                 );
                        //               } else {
                        //                 return SizedBox.shrink();
                        //               }
                        //             },
                        //           );
                        //         },
                        //       )
                        //     ],
                        //   ),
                        // )

                        // Expanded(
                        //   child: Row(
                        //     children: [
                        //       StreamBuilder<QuerySnapshot>(
                        //         stream: FirebaseFirestore.instance
                        //             .collection('requestToJoin')
                        //             .where('tournamentId',
                        //                 isEqualTo: widget.tournamentId)
                        //             .where('status', isEqualTo: 'approved')
                        //             .snapshots(),
                        //         builder: (BuildContext context,
                        //             AsyncSnapshot<QuerySnapshot> snapshot) {
                        //           if (snapshot.hasError) {
                        //             return Text('Error: ${snapshot.error}');
                        //           }

                        //           if (snapshot.connectionState ==
                        //               ConnectionState.waiting) {
                        //             return Text('Loading...');
                        //           }

                        //           if (!snapshot.hasData ||
                        //               snapshot.data!.docs.isEmpty) {
                        //             return Text('No accepted teams yet.');
                        //           }

                        //           return ListView.builder(
                        //             shrinkWrap: true,
                        //             scrollDirection: Axis.horizontal,
                        //             itemCount: snapshot.data!.docs.length,
                        //             itemBuilder: (context, index) {
                        //               final requestData =
                        //                   snapshot.data!.docs[index].data()
                        //                       as Map<String, dynamic>?;
                        //               final teamId = requestData?['teamId'];

                        //               if (teamId != null) {
                        //                 return FutureBuilder<QuerySnapshot>(
                        //                   future: FirebaseFirestore.instance
                        //                       .collection('teams')
                        //                       .doc(teamId)
                        //                       .collection('teams')
                        //                       .get(),
                        //                   builder: (BuildContext context,
                        //                       AsyncSnapshot<QuerySnapshot>
                        //                           snapshot) {
                        //                     if (snapshot.connectionState ==
                        //                         ConnectionState.waiting) {
                        //                       return Text('Loading team...');
                        //                     }

                        //                     if (!snapshot.hasData ||
                        //                         snapshot.data!.docs.isEmpty) {
                        //                       return Text(
                        //                           'Error: Team not found.');
                        //                     }

                        //                     final teamData =
                        //                         snapshot.data!.docs.first.data()
                        //                             as Map<String, dynamic>?;
                        //                     if (teamData == null) {
                        //                       return Text(
                        //                           'Error: Team not found.');
                        //                     }

                        //                     final teamName =
                        //                         teamData['teamName'];
                        //                     final logo = teamData['logo'];

                        //                     return Center(
                        //                       child: Padding(
                        //                         padding: const EdgeInsets
                        //                                 .symmetric(
                        //                             horizontal:
                        //                                 10.0), // adjust as needed
                        //                         child: Column(
                        //                           mainAxisAlignment:
                        //                               MainAxisAlignment.center,
                        //                           children: [
                        //                             Container(
                        //                               width: 60,
                        //                               height: 60,
                        //                               decoration: BoxDecoration(
                        //                                 borderRadius:
                        //                                     BorderRadius
                        //                                         .circular(10),
                        //                                 border: Border.all(
                        //                                     color: Color(
                        //                                         0xffFFA626),
                        //                                     width: 2),
                        //                                 image: DecorationImage(
                        //                                   fit: BoxFit.cover,
                        //                                   image: NetworkImage(
                        //                                       logo),
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                             SizedBox(
                        //                               height: 5,
                        //                             ),
                        //                             Text(
                        //                               '$teamName'.toUpperCase(),
                        //                               textAlign:
                        //                                   TextAlign.center,
                        //                               style: TextStyle(
                        //                                   fontFamily: 'karla',
                        //                                   fontSize: 14,
                        //                                   fontWeight:
                        //                                       FontWeight.w600),
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                     );
                        //                   },
                        //                 );
                        //               } else {
                        //                 return SizedBox(); // Handle the case when teamId is null
                        //               }
                        //             },
                        //           );
                        //         },
                        //       )
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // organize matches....
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        MatchOrganizerButton(
                          tournamentId: widget.tournamentId,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  // referees participating....
                  SizedBox(height: 20),
                  Container(
                    width: 1400,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffF2F0FF),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Referees Of The Tournament',
                                style: TextStyle(
                                    fontFamily: 'karla',
                                    fontSize: 26,
                                    color: Color(0xff6858FE)),
                              ),
                              Container(
                                width: 150,
                                height: 40,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.deepPurpleAccent),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddRefDialogue(
                                          tournamentId: widget.tournamentId,
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Create Referee',
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
                        Expanded(
                          child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: refereesDetailsStream(widget.tournamentId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.deepPurpleAccent));
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text('No Referees available'));
                              }

                              List<Map<String, dynamic>> refereesData =
                                  snapshot.data!;
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: refereesData.length,
                                itemBuilder: (context, index) {
                                  final referee = refereesData[index];
                                  return Container(
                                    width: 200,
                                    child: Card(
                                      color: Color(0xffFFF9F0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ListTile(
                                            title: Text(
                                              'Name: ${referee['name']}',
                                              style: TextStyle(
                                                fontFamily: 'karla',
                                              ),
                                            ),
                                            subtitle: Text(
                                                'Age: ${referee['age']}\nSpecialization: ${referee['specialization']}',
                                                style: TextStyle(
                                                  fontFamily: 'karla',
                                                )),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  _editReferee(referee['id']);
                                                },
                                                child: Text('Edit',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .deepPurpleAccent)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _deleteReferee(index);
                                                },
                                                child: Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .deepPurpleAccent)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void acceptedTeams(String teamId) {
    FirebaseFirestore.instance
        .collection('acceptedTeams')
        .doc(
            widget.tournamentId) // Use the tournamentId to specify the document
        .collection(
            'teams') // Create a subcollection 'teams' to store the team documents
        .add({
          'teamId': teamId,
        })
        .then((value) {})
        .catchError((error) {});
  }

  // Future<void> joinTournament(
  //   BuildContext context,
  //   String tournamentId,
  //   String userId,
  //   String teamId,
  // ) async {
  //   final requestRef = FirebaseFirestore.instance
  //       .collection('requestToJoin')
  //       .doc('$tournamentId');

  //   await requestRef.set({
  //     'tournamentId': tournamentId,
  //     'userId': userId,
  //     'teamId': teamId,
  //     'status': 'approved',
  //   });
  // }

// admin teams
  Future<List<QueryDocumentSnapshot>> fetchAdminTeams() async {
    final captainsSnapshot =
        await FirebaseFirestore.instance.collection('captains').get();
    List<QueryDocumentSnapshot> allTeams = [];

    for (var doc in captainsSnapshot.docs) {
      final teamsSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(doc.id)
          .collection('teams')
          .where('createdBy', isEqualTo: 'admin')
          .get();

      allTeams.addAll(teamsSnapshot.docs);
    }

    return allTeams;
  }

  Future<void> joinTournament(
    BuildContext context,
    String tournamentId,
    String userId,
    String teamId,
  ) async {
    await FirebaseFirestore.instance.collection('requestToJoin').add({
      'tournamentId': tournamentId,
      'userId': userId,
      'teamId': teamId,
      'status': 'approved',
      'createdBy': 'admin'
    });

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Team added to the tournament!')),
    // );
    Navigator.of(context).pop();
  }

  void showAdminTeams(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Admin Teams",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'karla',
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 900,
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: fetchAdminTeams(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                        child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent,
                    ));

                  final teams = snapshot.data!;

                  return DataTable(
                    columns: [
                      DataColumn(label: Text('teams')),
                      DataColumn(label: Text('Team Name')),
                      DataColumn(label: Text('Captain')),
                      DataColumn(label: Text('Club Name')),
                      DataColumn(
                        label: Text('Actions'),
                      ),

                      // Add more columns as needed
                    ],
                    rows: teams.map((teamDoc) {
                      final team = teamDoc.data() as Map<String, dynamic>;

                      return DataRow(
                        cells: [
                          DataCell(
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(team['logo'], scale: 1),
                            ),
                          ),
                          DataCell(Text(team['teamName'] ?? 'Unknown')),
                          DataCell(Text(team['captainname'] ?? 'Unknown')),
                          DataCell(Text(team['clubName'] ?? 'Unknown')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.deepPurpleAccent),
                                  ),
                                  onPressed: () {
                                    // Implement accept request functionality
                                    // acceptRequest(requestId, teamId);
                                    joinTournament(context, widget.tournamentId,
                                        team['captainId'], team['captainId']);
                                  },
                                  child: Text('Add'),
                                ),
                                // const SizedBox(width: 8),
                                // ElevatedButton(
                                //   style: ButtonStyle(
                                //     backgroundColor: MaterialStateProperty.all(
                                //         Colors.deepPurpleAccent),
                                //   ),
                                //   onPressed: () {
                                //     // Implement delete request functionality
                                //     deleteRequest(widget.tournamentId);
                                //   },
                                //   child: const Text('Delete'),
                                // ),
                              ],
                            ),
                          ),

                          // Add more cells as needed
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// teams join request send by users..
  void showTeamJoinRequests(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text(
              'Team Join Requests',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'karla',
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Container(
              width: 900, // Adjust this width based on your UI design
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requestToJoin')
                    .where('tournamentId', isEqualTo: widget.tournamentId)
                    .where('createdBy', isEqualTo: 'user')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No join requests yet.');
                  }

                  final joinRequests = snapshot.data!.docs.map((document) {
                    final requestData =
                        document.data() as Map<String, dynamic>?;
                    final requestId = document.id;
                    return {
                      'requestId': requestId,
                      'userId': requestData?['userId'],
                      'teamId': requestData?['teamId'],
                    };
                  }).toList();

                  return DataTable(
                    columns: const [
                      DataColumn(
                        label: Text('Serial Number'),
                      ),
                      DataColumn(
                        label: Text('Teams'),
                      ),
                      DataColumn(
                        label: Text('Team Name'),
                      ),
                      DataColumn(
                        label: Text('Club Name'),
                      ),
                      DataColumn(
                        label: Text('Actions'),
                      ),
                    ],
                    rows: joinRequests.map((joinRequest) {
                      final requestId = joinRequest['requestId'];
                      // final userId = joinRequest['userId'];
                      final teamId = joinRequest['teamId'];
                      return DataRow(cells: [
                        DataCell(Text(
                          '${joinRequests.indexOf(joinRequest) + 1}',
                          style: TextStyle(
                              fontFamily: 'karla',
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        )),
                        DataCell(
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('teams')
                                .doc(teamId)
                                .collection('teams')
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading team...');
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Text('Error: Team not found.');
                              }

                              final teamData = snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>?;
                              if (teamData == null) {
                                return Text('Error: Team not found.');
                              }

                              // final teamName = teamData['teamName'];
                              // final clubName = teamData['clubName'];
                              final logo = teamData['logo'];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(logo, scale: 1),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                        DataCell(
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('teams')
                                .doc(teamId)
                                .collection('teams')
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading team...');
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Text('Error: Team not found.');
                              }

                              final teamData = snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>?;
                              if (teamData == null) {
                                return Text('Error: Team not found.');
                              }

                              final teamName = teamData['teamName'];
                              // final clubName = teamData['clubName'];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$teamName',
                                    style: TextStyle(
                                        fontFamily: 'karla',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        DataCell(
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('teams')
                                .doc(teamId)
                                .collection('teams')
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading team...');
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Text('Error: Team not found.');
                              }

                              final teamData = snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>?;
                              if (teamData == null) {
                                return Text('Error: Team not found.');
                              }

                              final clubName = teamData['clubName'];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$clubName',
                                    style: TextStyle(
                                        fontFamily: 'karla',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.deepPurpleAccent),
                                ),
                                onPressed: () {
                                  // Implement accept request functionality
                                  acceptRequest(requestId, teamId);
                                },
                                child: Text('Accept'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.deepPurpleAccent),
                                ),
                                onPressed: () {
                                  // Implement delete request functionality
                                  deleteRequest(requestId);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  );
                },
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.deepPurpleAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void acceptRequest(String requestId, String teamId) {
    FirebaseFirestore.instance
        .collection('requestToJoin')
        .doc(requestId)
        .update({'status': 'approved'}).then((value) {
      acceptedTeams(teamId); // Call acceptedTeams method
    }).catchError((error) {
      print('Failed to accept join request: $error');
    });
  }

  void deleteRequest(String requestId) {
    FirebaseFirestore.instance
        .collection('requestToJoin')
        .doc(requestId)
        .delete()
        .then((value) => print('Join request deleted.'))
        .catchError((error) => print('Failed to delete join request: $error'));
  }
}

// void acceptRequest(String requestId, String teamId) {
//   FirebaseFirestore.instance
//       .collection('requestToJoin')
//       .doc(requestId)
//       .update({'status': 'approved'}).then((value) {
//     acceptedTeams(teamId); // Call acceptedTeams method
//   }).catchError((error) {
//     print('Failed to accept join request: $error');
//   });
// }

// void deleteRequest(String requestId) {
//   FirebaseFirestore.instance
//       .collection('requestToJoin')
//       .doc(requestId)
//       .delete()
//       .then((value) => print('Join request deleted.'))
//       .catchError((error) => print('Failed to delete join request: $error'));
// }

//  Text(
//             'Join Requests:',
//             style: TextStyle(
//               fontSize: 20,
//               fontFamily: 'karla',
//               color: Colors.deepPurpleAccent,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('requestToJoin')
//                       .where('tournamentId', isEqualTo: tournamentId)
//                       .snapshots(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     }

//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Text('Loading...');
//                     }

//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Text('No join requests yet.');
//                     }

//                     final joinRequests = snapshot.data!.docs.map((document) {
//                       final requestData =
//                           document.data() as Map<String, dynamic>?;
//                       final requestId = document.id;

//                       return {
//                         'requestId': requestId,
//                         'userId': requestData?['userId'],
//                         'teamId': requestData?['teamId'],
//                       };
//                     }).toList();

//                     return DataTable(
//                       columns: const [
//                         DataColumn(
//                           label: Text(
//                             'Serial Number',
//                             style: TextStyle(
//                                 fontFamily: 'karla',
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         DataColumn(
//                           label: Text(
//                             'Teams',
//                             style: TextStyle(
//                                 fontFamily: 'karla',
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         DataColumn(
//                             label: Text(
//                           'Team Name',
//                           style: TextStyle(
//                               fontFamily: 'karla',
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold),
//                         )),
//                         DataColumn(
//                             label: Text('Club Name',
//                                 style: TextStyle(
//                                     fontFamily: 'karla',
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold))),
//                         DataColumn(
//                             label: Text('Actions',
//                                 style: TextStyle(
//                                     fontFamily: 'karla',
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold))),
//                       ],
// rows: joinRequests.map((joinRequest) {
//   final requestId = joinRequest['requestId'];
//   // final userId = joinRequest['userId'];
//   final teamId = joinRequest['teamId'];
//   return DataRow(cells: [
//     DataCell(Text(
//       '${joinRequests.indexOf(joinRequest) + 1}',
//       style: TextStyle(
//           fontFamily: 'karla',
//           fontSize: 18,
//           fontWeight: FontWeight.w500),
//     )),
//     DataCell(
//       FutureBuilder<QuerySnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('teams')
//             .doc(teamId)
//             .collection('teams')
//             .get(),
//         builder: (BuildContext context,
//             AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return Text('Loading team...');
//           }

//           if (!snapshot.hasData ||
//               snapshot.data!.docs.isEmpty) {
//             return Text('Error: Team not found.');
//           }

//           final teamData = snapshot.data!.docs.first
//               .data() as Map<String, dynamic>?;
//           if (teamData == null) {
//             return Text('Error: Team not found.');
//           }

//           // final teamName = teamData['teamName'];
//           // final clubName = teamData['clubName'];
//           final logo = teamData['logo'];

//           return Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 backgroundImage:
//                     NetworkImage(logo, scale: 1),
//               )
//             ],
//           );
//         },
//       ),
//     ),
//     DataCell(
//       FutureBuilder<QuerySnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('teams')
//             .doc(teamId)
//             .collection('teams')
//             .get(),
//         builder: (BuildContext context,
//             AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return Text('Loading team...');
//           }

//           if (!snapshot.hasData ||
//               snapshot.data!.docs.isEmpty) {
//             return Text('Error: Team not found.');
//           }

//           final teamData = snapshot.data!.docs.first
//               .data() as Map<String, dynamic>?;
//           if (teamData == null) {
//             return Text('Error: Team not found.');
//           }

//           final teamName = teamData['teamName'];
//           // final clubName = teamData['clubName'];

//           return Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '$teamName',
//                 style: TextStyle(
//                     fontFamily: 'karla',
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500),
//               ),
//             ],
//           );
//         },
//       ),
//     ),
//     DataCell(
//       FutureBuilder<QuerySnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('teams')
//             .doc(teamId)
//             .collection('teams')
//             .get(),
//         builder: (BuildContext context,
//             AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return Text('Loading team...');
//           }

//           if (!snapshot.hasData ||
//               snapshot.data!.docs.isEmpty) {
//             return Text('Error: Team not found.');
//           }

//           final teamData = snapshot.data!.docs.first
//               .data() as Map<String, dynamic>?;
//           if (teamData == null) {
//             return Text('Error: Team not found.');
//           }

//           final clubName = teamData['clubName'];

//           return Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '$clubName',
//                 style: TextStyle(
//                     fontFamily: 'karla',
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500),
//               ),
//             ],
//           );
//         },
//       ),
//     ),
//     DataCell(
//       Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor:
//                   MaterialStateProperty.all(
//                       Colors.deepPurpleAccent),
//             ),
//             onPressed: () {
//               // Implement accept request functionality
//               acceptRequest(requestId, teamId);
//             },
//             child: Text('Accept'),
//           ),
//           const SizedBox(width: 8),
//           ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor:
//                   MaterialStateProperty.all(
//                       Colors.deepPurpleAccent),
//             ),
//             onPressed: () {
//               // Implement delete request functionality
//               deleteRequest(requestId);
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     ),
//   ]);
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 32,
//           ),
//           Text(
//             'Accepted Teams:',
//             style: TextStyle(
//               fontSize: 20,
//               fontFamily: 'karla',
//               color: Colors.deepPurpleAccent,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16),
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('requestToJoin')
//                 .where('tournamentId', isEqualTo: tournamentId)
//                 .where('status', isEqualTo: 'approved')
//                 .snapshots(),
//             builder: (BuildContext context,
//                 AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               }

//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Text('Loading...');
//               }

//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Text('No accepted teams yet.');
//               }

//               return GridView.builder(
//                 shrinkWrap: true,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 5,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   final requestData = snapshot.data!.docs[index].data()
//                       as Map<String, dynamic>?;
//                   final teamId = requestData?['teamId'];

//                   if (teamId != null) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: Colors.amberAccent[100],
//                       ),
//                       child: FutureBuilder<QuerySnapshot>(
//                         future: FirebaseFirestore.instance
//                             .collection('teams')
//                             .doc(teamId)
//                             .collection('teams')
//                             .get(),
//                         builder: (BuildContext context,
//                             AsyncSnapshot<QuerySnapshot> snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return Text('Loading team...');
//                           }

//                           if (!snapshot.hasData ||
//                               snapshot.data!.docs.isEmpty) {
//                             return Text('Error: Team not found.');
//                           }

//                           final teamData = snapshot.data!.docs.first.data()
//                               as Map<String, dynamic>?;
//                           if (teamData == null) {
//                             return Text('Error: Team not found.');
//                           }

//                           final teamName = teamData['teamName'];
//                           // final clubName = teamData['clubName'];
//                           final logo = teamData['logo'];

//                           return Card(
//                             elevation: 5,
//                             child: Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Image.network(logo),
//                                   SizedBox(
//                                     height: 15,
//                                   ),
//                                   Text(
//                                     textAlign: TextAlign.center,
//                                     '$teamName'.toUpperCase(),
//                                     style: TextStyle(
//                                         fontFamily: 'karla',
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   } else {
//                     return SizedBox(); // Handle the case when teamId is null
//                   }
//                 },
//               );
//             },
//           ),
