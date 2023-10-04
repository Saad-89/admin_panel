import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../matchOrganizingWidget.dart';

class SecondRoundMatchScheduleWidget extends StatefulWidget {
  final String tournamentId;
  SecondRoundMatchScheduleWidget({required this.tournamentId});
  @override
  _SecondRoundMatchScheduleWidgetState createState() =>
      _SecondRoundMatchScheduleWidgetState();
}

class _SecondRoundMatchScheduleWidgetState
    extends State<SecondRoundMatchScheduleWidget> {
  StreamSubscription? _teamsSubscription;

  @override
  void initState() {
    super.initState();
    _teamsSubscription = FirebaseFirestore.instance
        .collection('matchSchedule')
        .doc(widget.tournamentId)
        .collection('nextRound')
        .doc('winner')
        .collection('teams')
        .snapshots()
        .listen((snapshot) async {
      List<String> teamIds = snapshot.docs.map((doc) => doc.id).toList();
      if (teamIds.length == 4) {
        final matchesExist = await FirebaseFirestore.instance
            .collection('matchSchedule')
            .doc(widget.tournamentId)
            .collection('secondRoundMatches')
            .get();

        if (matchesExist.docs.isEmpty) {
          organizeAutomaticMatches(teamIds);
        }
      }
    });
  }

  DateTime randomDateInTheNextTenDays() {
    final today = DateTime.now();
    final randomDays = Random().nextInt(10);
    return today.add(Duration(days: randomDays));
  }

  Future<List<String>> _fetchRefereeNames() async {
    final firestore = FirebaseFirestore.instance;
    List<String> refereeNames = [];
    DocumentSnapshot eventDoc =
        await firestore.collection('events').doc(widget.tournamentId).get();
    Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
    List<String> refereeDocIds =
        List<String>.from(eventData['refereesDocIds'] ?? []);
    for (String id in refereeDocIds) {
      DocumentSnapshot refDoc =
          await firestore.collection('referees').doc(id).get();
      Map<String, dynamic> refData = refDoc.data() as Map<String, dynamic>;
      String name = refData['name'] ?? '';
      refereeNames.add(name);
    }
    return refereeNames;
  }

  List<String> _availableTimes = [
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM'
  ];

  Future<void> organizeAutomaticMatches(List<String> teamIds) async {
    final firestore = FirebaseFirestore.instance;
    List<String> availableReferees = await _fetchRefereeNames();
    if (availableReferees.isEmpty) return;
    teamIds.shuffle();
    for (int i = 0; i < 4; i += 2) {
      String team1 = teamIds[i];
      String team2 = teamIds[i + 1];
      DateTime date = randomDateInTheNextTenDays();
      String formattedDate = '${date.day}-${date.month}-${date.year}';
      String selectedTime =
          _availableTimes[Random().nextInt(_availableTimes.length)];
      String selectedReferee =
          availableReferees[Random().nextInt(availableReferees.length)];
      await firestore
          .collection('matchSchedule')
          .doc(widget.tournamentId)
          .collection('secondRoundMatches')
          .add({
        'matchNumber': (i ~/ 2 + 1).toString(),
        'team1Id': team1,
        'team2Id': team2,
        'matchDate': formattedDate,
        'matchTime': selectedTime,
        'ground': 'add ground',
        'referee': selectedReferee,
        'stage': 'semi final'
      });
    }
  }

  @override
  void dispose() {
    _teamsSubscription?.cancel();
    super.dispose();
  }

  void showUpdateMatchDialog(
      BuildContext context,
      String matchId,
      String team1Id,
      String team2Id,
      String matchNumber,
      dynamic matchDate,
      String matchTime,
      String ground,
      String referee) {
    showDialog(
      context: context,
      builder: (context) => MatchUpdaterDialogForSemiFinals(
        tournamentId: widget.tournamentId,
        matchId: matchId,
        team1Id: team1Id,
        team2Id: team2Id,
        matchNumber: matchNumber,
        matchDate: matchDate,
        matchTime: matchTime,
        ground: ground,
        referee: referee,
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context, String matchId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this match?'),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Colors.deepPurpleAccent)),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('matchSchedule')
                  .doc(widget.tournamentId)
                  .collection('secondRoundMatches')
                  .doc(matchId)
                  .delete()
                  .then((_) {
                Navigator.pop(context);
              }).catchError((error) {
                Navigator.pop(context);
              });
            },
            child: Text('Delete'),
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Colors.deepPurpleAccent)),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('SemiFinal Matches',
                style: TextStyle(
                    fontFamily: 'karla',
                    fontSize: 26,
                    color: Color(0xff6858FE))),
          ],
        ),
        SizedBox(height: 15),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('matchSchedule')
              .doc(widget.tournamentId)
              .collection('secondRoundMatches')
              .orderBy('matchNumber', descending: false)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              final matches = snapshot.data!.docs;

              return SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: matches.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final matchData = match.data() as Map<String, dynamic>;
                    final matchId = match.id;
                    final matchNumber = matchData['matchNumber'];
                    final team1Id = matchData['team1Id'];
                    final team2Id = matchData['team2Id'];
                    final matchDate = matchData['matchDate'];
                    final matchTime = matchData['matchTime'];
                    final ground = matchData['ground'];
                    final referee = matchData['referee'];

                    return Container(
                      height: 400,
                      decoration: BoxDecoration(
                          color: Color(0xffF2F0FF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('teams')
                                  .doc(team1Id)
                                  .collection('teams')
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  final team1Data = snapshot.data!.docs.first
                                      .data() as Map<String, dynamic>;
                                  final team1Name =
                                      team1Data['teamName'] ?? 'Unknown';
                                  final team1Logo =
                                      team1Data['logo'] ?? 'Unknown';

                                  return FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('teams')
                                        .doc(team2Id)
                                        .collection('teams')
                                        .get(),
                                    builder: (context, team2Snapshot) {
                                      if (team2Snapshot.connectionState ==
                                              ConnectionState.done &&
                                          team2Snapshot.hasData) {
                                        final team2Data = team2Snapshot
                                            .data!.docs.first
                                            .data() as Map<String, dynamic>;
                                        final team2Name =
                                            team2Data['teamName'] ?? 'Unknown';
                                        final team2Logo =
                                            team2Data['logo'] ?? 'Unknown';
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xffFFA626),
                                                        width: 2),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            team1Logo)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  team1Name,
                                                  style: TextStyle(
                                                      fontFamily: 'karla'),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text('VS'),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xffFFA626),
                                                        width: 2),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            team2Logo)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  team2Name,
                                                  style: TextStyle(
                                                      fontFamily: 'karla'),
                                                )
                                              ],
                                            ),
                                          ],
                                        );
                                      }
                                      return Text('Loading team 2...');
                                    },
                                  );
                                }
                                return Text('Loading team 1...');
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(0xffFFA626),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  '$matchDate/$matchTime',
                                  style: TextStyle(
                                      fontFamily: 'karla', color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(0xff6858FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  '$ground',
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: 'karla',
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(0xffFFA626),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: referee == null
                                    ? Text('Select Referee')
                                    : Text(
                                        '$referee',
                                        style: TextStyle(
                                            fontFamily: 'karla',
                                            color: Colors.white),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                        fontFamily: 'karla',
                                        color: Color(0xff6858FE)),
                                  ),
                                  onPressed: () {
                                    showUpdateMatchDialog(
                                      context,
                                      matchId,
                                      team1Id,
                                      team2Id,
                                      matchNumber,
                                      matchDate,
                                      matchTime,
                                      ground,
                                      referee,
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        fontFamily: 'karla',
                                        color: Color(0xff6858FE)),
                                  ),
                                  onPressed: () {
                                    showDeleteConfirmation(context, matchId);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return Center(
                child: CircularProgressIndicator(
              color: Colors.deepPurpleAccent,
            ));
          },
        ),
      ],
    );
  }
}

// class SecondRoundMatchScheduleWidget extends StatefulWidget {
//   final String tournamentId;
//   SecondRoundMatchScheduleWidget({required this.tournamentId});
//   @override
//   _SecondRoundMatchScheduleWidgetState createState() =>
//       _SecondRoundMatchScheduleWidgetState();
// }

// class _SecondRoundMatchScheduleWidgetState
//     extends State<SecondRoundMatchScheduleWidget> {
//   StreamSubscription? _teamsSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _teamsSubscription = FirebaseFirestore.instance
//         .collection('matchSchedule')
//         .doc(widget.tournamentId)
//         .collection('nextRound')
//         .doc('winner')
//         .collection('teams')
//         .snapshots()
//         .listen((snapshot) {
//       List<String> teamIds = snapshot.docs.map((doc) => doc.id).toList();
//       if (teamIds.length == 4) {
//         organizeAutomaticMatches(teamIds);
//       }
//     });
//   }

//   DateTime randomDateInTheNextTenDays() {
//     final today = DateTime.now();
//     final randomDays = Random().nextInt(10);
//     return today.add(Duration(days: randomDays));
//   }

//   Future<List<String>> _fetchRefereeNames() async {
//     final firestore = FirebaseFirestore.instance;
//     List<String> refereeNames = [];
//     DocumentSnapshot eventDoc =
//         await firestore.collection('events').doc(widget.tournamentId).get();
//     Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
//     List<String> refereeDocIds =
//         List<String>.from(eventData['refereesDocIds'] ?? []);
//     for (String id in refereeDocIds) {
//       DocumentSnapshot refDoc =
//           await firestore.collection('referees').doc(id).get();
//       Map<String, dynamic> refData = refDoc.data() as Map<String, dynamic>;
//       String name = refData['name'] ?? '';
//       refereeNames.add(name);
//     }
//     return refereeNames;
//   }

//   List<String> _availableTimes = [
//     '06:00 PM',
//     '07:00 PM',
//     '08:00 PM',
//     '09:00 PM'
//   ];

//   Future<void> organizeAutomaticMatches(List<String> teamIds) async {
//     final firestore = FirebaseFirestore.instance;
//     List<String> availableReferees = await _fetchRefereeNames();
//     if (availableReferees.isEmpty) return;
//     teamIds.shuffle();
//     for (int i = 0; i < 4; i += 2) {
//       String team1 = teamIds[i];
//       String team2 = teamIds[i + 1];
//       DateTime date = randomDateInTheNextTenDays();
//       String formattedDate = '${date.day}-${date.month}-${date.year}';
//       String selectedTime =
//           _availableTimes[Random().nextInt(_availableTimes.length)];
//       String selectedReferee =
//           availableReferees[Random().nextInt(availableReferees.length)];
//       await firestore
//           .collection('matchSchedule')
//           .doc(widget.tournamentId)
//           .collection('secondRoundMatches')
//           .add({
//         'matchNumber': (i ~/ 2 + 1).toString(),
//         'team1Id': team1,
//         'team2Id': team2,
//         'matchDate': formattedDate,
//         'matchTime': selectedTime,
//         'ground': 'add ground',
//         'referee': selectedReferee,
//         'stage': 'semi final'
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _teamsSubscription?.cancel();
//     super.dispose();
//   }

//   void showUpdateMatchDialog(
//       BuildContext context,
//       String matchId,
//       String team1Id,
//       String team2Id,
//       String matchNumber,
//       dynamic matchDate,
//       String matchTime,
//       String ground,
//       String referee) {
//     showDialog(
//       context: context,
//       builder: (context) => MatchUpdaterDialogForSemiFinals(
//         tournamentId: widget.tournamentId,
//         matchId: matchId,
//         team1Id: team1Id,
//         team2Id: team2Id,
//         matchNumber: matchNumber,
//         matchDate: matchDate,
//         matchTime: matchTime,
//         ground: ground,
//         referee: referee,
//       ),
//     );
//   }

//   void showDeleteConfirmation(BuildContext context, String matchId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Confirm Delete'),
//         content: Text('Are you sure you want to delete this match?'),
//         actions: [
//           ElevatedButton(
//             style: ButtonStyle(
//                 backgroundColor:
//                     MaterialStatePropertyAll(Colors.deepPurpleAccent)),
//             onPressed: () {
//               FirebaseFirestore.instance
//                   .collection('matchSchedule')
//                   .doc(widget.tournamentId)
//                   .collection('secondRoundMatches')
//                   .doc(matchId)
//                   .delete()
//                   .then((_) {
//                 Navigator.pop(context);
//               }).catchError((error) {
//                 Navigator.pop(context);
//               });
//             },
//             child: Text('Delete'),
//           ),
//           ElevatedButton(
//             style: ButtonStyle(
//                 backgroundColor:
//                     MaterialStatePropertyAll(Colors.deepPurpleAccent)),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text('SemiFinal Matches',
//                 style: TextStyle(
//                     fontFamily: 'karla',
//                     fontSize: 26,
//                     color: Color(0xff6858FE))),
//           ],
//         ),
//         SizedBox(height: 15),
//         StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('matchSchedule')
//               .doc(widget.tournamentId)
//               .collection('secondRoundMatches')
//               .orderBy('matchNumber', descending: false)
//               .snapshots(),
//           builder:
//               (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.hasData) {
//               final matches = snapshot.data!.docs;

//               return SingleChildScrollView(
//                 child: GridView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: matches.length,
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 4,
//                     crossAxisSpacing: 8,
//                     mainAxisSpacing: 8,
//                   ),
//                   itemBuilder: (context, index) {
//                     final match = matches[index];
//                     final matchData = match.data() as Map<String, dynamic>;
//                     final matchId = match.id;
//                     final matchNumber = matchData['matchNumber'];
//                     final team1Id = matchData['team1Id'];
//                     final team2Id = matchData['team2Id'];
//                     final matchDate = matchData['matchDate'];
//                     final matchTime = matchData['matchTime'];
//                     final ground = matchData['ground'];
//                     final referee = matchData['referee'];

//                     return Container(
//                       height: 400,
//                       decoration: BoxDecoration(
//                           color: Color(0xffF2F0FF),
//                           borderRadius: BorderRadius.circular(10)),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Text(
//                             //   'Match Number $matchNumber',
//                             //   style: TextStyle(
//                             //       fontFamily: 'karla',
//                             //       fontSize: 20,
//                             //       fontWeight: FontWeight.w400),
//                             // ),
//                             // SizedBox(
//                             //   height: 20,
//                             // ),
//                             FutureBuilder<QuerySnapshot>(
//                               future: FirebaseFirestore.instance
//                                   .collection('teams')
//                                   .doc(team1Id)
//                                   .collection('teams')
//                                   .get(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState ==
//                                         ConnectionState.done &&
//                                     snapshot.hasData) {
//                                   final team1Data = snapshot.data!.docs.first
//                                       .data() as Map<String, dynamic>;
//                                   final team1Name =
//                                       team1Data['teamName'] ?? 'Unknown';
//                                   final team1Logo =
//                                       team1Data['logo'] ?? 'Unknown';

//                                   return FutureBuilder<QuerySnapshot>(
//                                     future: FirebaseFirestore.instance
//                                         .collection('teams')
//                                         .doc(team2Id)
//                                         .collection('teams')
//                                         .get(),
//                                     builder: (context, team2Snapshot) {
//                                       if (team2Snapshot.connectionState ==
//                                               ConnectionState.done &&
//                                           team2Snapshot.hasData) {
//                                         final team2Data = team2Snapshot
//                                             .data!.docs.first
//                                             .data() as Map<String, dynamic>;
//                                         final team2Name =
//                                             team2Data['teamName'] ?? 'Unknown';
//                                         final team2Logo =
//                                             team2Data['logo'] ?? 'Unknown';
//                                         return Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Column(
//                                               children: [
//                                                 Container(
//                                                   width: 50,
//                                                   height: 50,
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     border: Border.all(
//                                                         color:
//                                                             Color(0xffFFA626),
//                                                         width: 2),
//                                                     image: DecorationImage(
//                                                         fit: BoxFit.cover,
//                                                         image: NetworkImage(
//                                                             team1Logo)),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   height: 5,
//                                                 ),
//                                                 Text(
//                                                   team1Name,
//                                                   style: TextStyle(
//                                                       fontFamily: 'karla'),
//                                                 )
//                                               ],
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Text('VS'),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Column(
//                                               children: [
//                                                 Container(
//                                                   width: 50,
//                                                   height: 50,
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     border: Border.all(
//                                                         color:
//                                                             Color(0xffFFA626),
//                                                         width: 2),
//                                                     image: DecorationImage(
//                                                         fit: BoxFit.cover,
//                                                         image: NetworkImage(
//                                                             team2Logo)),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   height: 5,
//                                                 ),
//                                                 Text(
//                                                   team2Name,
//                                                   style: TextStyle(
//                                                       fontFamily: 'karla'),
//                                                 )
//                                               ],
//                                             ),
//                                           ],
//                                         );
//                                       }
//                                       return Text('Loading team 2...');
//                                     },
//                                   );
//                                 }
//                                 return Text('Loading team 1...');
//                               },
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Container(
//                               width: 200,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: Color(0xffFFA626),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   '$matchDate/$matchTime',
//                                   style: TextStyle(
//                                       fontFamily: 'karla', color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Container(
//                               width: 200,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: Color(0xff6858FE),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   '$ground',
//                                   style: TextStyle(
//                                       overflow: TextOverflow.ellipsis,
//                                       fontFamily: 'karla',
//                                       color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Container(
//                               width: 200,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: Color(0xffFFA626),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Center(
//                                 child: referee == null
//                                     ? Text('Select Referee')
//                                     : Text(
//                                         '$referee',
//                                         style: TextStyle(
//                                             fontFamily: 'karla',
//                                             color: Colors.white),
//                                       ),
//                               ),
//                             ),
//                             // Text('Venue: $ground'),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 TextButton(
//                                   child: Text(
//                                     'Edit',
//                                     style: TextStyle(
//                                         fontFamily: 'karla',
//                                         color: Color(0xff6858FE)),
//                                   ),
//                                   onPressed: () {
//                                     print('edit match');
//                                     print('matchDate: $matchDate');
//                                     print('referee: $referee');
//                                     print('matchId: $matchId');

//                                     showUpdateMatchDialog(
//                                       context,
//                                       matchId,
//                                       team1Id,
//                                       team2Id,
//                                       matchNumber,
//                                       matchDate,
//                                       matchTime,
//                                       ground,
//                                       referee,
//                                     );
//                                   },
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 TextButton(
//                                   child: Text(
//                                     'Delete',
//                                     style: TextStyle(
//                                         fontFamily: 'karla',
//                                         color: Color(0xff6858FE)),
//                                   ),
//                                   onPressed: () {
//                                     showDeleteConfirmation(context, matchId);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             }
//             return Center(
//                 child: CircularProgressIndicator(
//               color: Colors.deepPurpleAccent,
//             ));
//           },
//         ),
//       ],
//     );
//   }
// }

class MatchUpdaterDialogForSemiFinals extends StatefulWidget {
  final String tournamentId;
  final String matchId;
  late String team1Id;
  late String team2Id;
  final String matchNumber;
  final String matchDate;
  final String matchTime;
  final String ground;
  late String referee;

  MatchUpdaterDialogForSemiFinals({
    required this.tournamentId,
    required this.matchId,
    required this.team1Id,
    required this.team2Id,
    required this.matchNumber,
    required this.matchDate,
    required this.matchTime,
    required this.ground,
    required this.referee,
  });

  @override
  _MatchUpdaterDialogForSemiFinalsState createState() =>
      _MatchUpdaterDialogForSemiFinalsState();
}

class _MatchUpdaterDialogForSemiFinalsState
    extends State<MatchUpdaterDialogForSemiFinals> {
  late TextEditingController matchNumberController;
  late TextEditingController matchDateController;
  late TextEditingController matchTimeController;
  late TextEditingController groundController;

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
        matchDateController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  // select time...

  List<String> _availableTimes = [];

  void generateAvailableTimes() {
    for (int hour = 1; hour <= 12; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        _availableTimes.add(
            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} AM");
      }
    }
    for (int hour = 1; hour <= 12; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        _availableTimes.add(
            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} PM");
      }
    }
  }

  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    generateAvailableTimes();

    _selectedTime = widget.matchTime;
    selectedReferee = widget.referee;

    matchNumberController = TextEditingController(text: widget.matchNumber);
    matchDateController = TextEditingController(text: widget.matchDate);
    matchTimeController = TextEditingController(text: widget.matchTime);
    groundController = TextEditingController(text: widget.ground);
  }

  @override
  void dispose() {
    matchNumberController.dispose();
    matchDateController.dispose();
    matchTimeController.dispose();
    groundController.dispose();
    super.dispose();
  }

  String? selectedReferee;

  void updateMatch(String selectTime) {
    final matchNumber = matchNumberController.text;
    final matchDate = matchDateController.text;
    final matchTime = matchTimeController.text;
    final ground = groundController.text;

    if (matchNumber.isNotEmpty &&
        // matchDate.isNotEmpty &&
        // matchTime.isNotEmpty &&
        ground.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('matchSchedule')
          .doc(widget.tournamentId)
          .collection('secondRoundMatches')
          .doc(widget.matchId)
          .update({
        'matchNumber': matchNumber,
        'team1Id': widget.team1Id,
        'team2Id': widget.team2Id,
        'matchDate': matchDateController.text,
        'matchTime': selectTime,
        'ground': ground,
        'referee': selectedReferee,
      }).then((_) {
        print('Match updated successfully.');
        Navigator.pop(context); // Close the dialogue after successful update
      }).catchError((error) {
        print('Failed to update match: $error');
      });
    } else {
      print('Please fill in all fields');
    }
  }

  Future<List<String>> _fetchRefereeNames(List<String> docIds) async {
    final firestore = FirebaseFirestore.instance;
    List<String> refereeNames = [];

    for (var id in docIds) {
      DocumentSnapshot refDoc =
          await firestore.collection('referees').doc(id).get();

      // Explicitly cast the data from refDoc to a Map<String, dynamic>
      Map<String, dynamic> refereeData = refDoc.data() as Map<String, dynamic>;

      // Then retrieve the name using the casted refereeData
      if (refDoc.exists && refereeData.containsKey('name')) {
        String name = refereeData['name'] as String;
        refereeNames.add(name);
      }
    }

    return refereeNames;
  }

  @override
  Widget build(BuildContext context) {
    print('team 1 id ${widget.team1Id}');
    print('team 2 id ${widget.team2Id}');
    print('referee ${widget.referee}');

    return Dialog(
      insetPadding: EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Update Match',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Match Number',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: matchNumberController,
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
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Team 1',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: StreamBuilder<QuerySnapshot>(
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

                            final teams = snapshot.data!.docs;
                            return DropdownButtonFormField<String>(
                              value: widget.team1Id,
                              onChanged: (String? newValue) {
                                setState(() {
                                  widget.team1Id = newValue!;
                                });
                              },
                              items: teams.map((teamDoc) {
                                final requestData =
                                    teamDoc.data() as Map<String, dynamic>?;
                                final teamId = requestData?['teamId'];

                                if (teamId != null) {
                                  return DropdownMenuItem<String>(
                                    value: teamId,
                                    child: FutureBuilder<QuerySnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('teams')
                                          .doc(teamId)
                                          .collection('teams')
                                          .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text('Loading team...');
                                        }

                                        if (!snapshot.hasData ||
                                            snapshot.data!.docs.isEmpty) {
                                          return Text('Error: Team not found.');
                                        }

                                        final teamData =
                                            snapshot.data!.docs.first.data()
                                                as Map<String, dynamic>?;
                                        if (teamData == null) {
                                          return Text('Error: Team not found.');
                                        }

                                        final teamName = teamData['teamName'];
                                        return Text('$teamName');
                                      },
                                    ),
                                  );
                                } else {
                                  return DropdownMenuItem<String>(
                                    value: '',
                                    child: Text('No team found'),
                                  );
                                }
                              }).toList(),
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Team 2',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: StreamBuilder<QuerySnapshot>(
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

                            final teams = snapshot.data!.docs;
                            return DropdownButtonFormField<String>(
                              value: widget.team2Id,
                              onChanged: (String? newValue) {
                                setState(() {
                                  widget.team2Id = newValue!;
                                });
                              },
                              items: teams.map((teamDoc) {
                                final requestData =
                                    teamDoc.data() as Map<String, dynamic>?;
                                final teamId = requestData?['teamId'];

                                if (teamId != null) {
                                  return DropdownMenuItem<String>(
                                    value: teamId,
                                    child: FutureBuilder<QuerySnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('teams')
                                          .doc(teamId)
                                          .collection('teams')
                                          .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text('Loading team...');
                                        }

                                        if (!snapshot.hasData ||
                                            snapshot.data!.docs.isEmpty) {
                                          return Text('Error: Team not found.');
                                        }

                                        final teamData =
                                            snapshot.data!.docs.first.data()
                                                as Map<String, dynamic>?;
                                        if (teamData == null) {
                                          return Text('Error: Team not found.');
                                        }

                                        final teamName = teamData['teamName'];
                                        return Text('$teamName');
                                      },
                                    ),
                                  );
                                } else {
                                  return DropdownMenuItem<String>(
                                    value: '',
                                    child: Text('No team found'),
                                  );
                                }
                              }).toList(),
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Date',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          readOnly: true,
                          controller: matchDateController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
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
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Time',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xffEEEEEE), // Background color
                            borderRadius:
                                BorderRadius.circular(4), // Rounded corners
                            border: Border.all(
                              color: Color(0xffEEEEEE), // Border color
                              width: 0.5, // Border width
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              // hint: Text('Select a time'),
                              value: _selectedTime,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.black),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              items: _availableTimes.map((String time) {
                                return DropdownMenuItem<String>(
                                  value: time,
                                  child: Text(time),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTime = newValue;
                                  print("Selected Time: $_selectedTime");
                                });
                              },
                              dropdownColor: Colors.white,
                              isExpanded: true,
                            ),
                          ),
                        ),
                        // DropdownButtonHideUnderline(
                        //   child: DropdownButton<String>(
                        //     hint: Text(
                        //         '${matchTimeController.text.toString()}'),
                        //     value: _selectedTime,
                        //     icon: Icon(Icons.arrow_drop_down,
                        //         color: Colors
                        //             .black), // Style the dropdown icon if you want
                        //     style: TextStyle(
                        //         color: Colors.black,
                        //         fontSize: 18,
                        //         fontWeight: FontWeight
                        //             .w500), // This is the style for the text displayed in dropdown
                        //     items: _availableTimes.map((String time) {
                        //       return DropdownMenuItem<String>(
                        //         value: time,
                        //         child: Text(time),
                        //       );
                        //     }).toList(),
                        //     onChanged: (String? newValue) {
                        //       setState(() {
                        //         _selectedTime = newValue;
                        //         print("Selected Time: $_selectedTime");
                        //       });
                        //     },
                        //     dropdownColor: Colors
                        //         .white, // This sets the background color of dropdown items
                        //     isExpanded:
                        //         true, // To make sure the dropdown expands to fill its parent
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Ground',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: groundController,
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
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Referee',
                          style: TextStyle(fontFamily: 'karla', fontSize: 18),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('events')
                              .doc(widget.tournamentId)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return DropdownButtonFormField<String>(
                                items: [],
                                onChanged: null,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEEEEEE),
                                  hintText: 'Loading...',
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
                              );
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Text('No referees data available');
                            }

                            List<String> refereesDocIds = snapshot.data!
                                .get('refereesDocIds')
                                .cast<String>();

                            // Now use FutureBuilder to retrieve referee names based on the doc IDs
                            return FutureBuilder<List<String>>(
                              future: _fetchRefereeNames(refereesDocIds),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<String>> snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text('Fetching referees...');
                                }
                                if (snap.hasError) {
                                  return Text(
                                      'Error fetching referees: ${snap.error}');
                                }
                                if (!snap.hasData || snap.data!.isEmpty) {
                                  return Text('No referees available');
                                }
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xffEEEEEE),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Color(0xffEEEEEE),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedReferee,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedReferee = newValue;
                                        });
                                      },
                                      items: snap.data!.map((String ref) {
                                        return DropdownMenuItem<String>(
                                          value: ref,
                                          child: Text(ref),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Color(0xffEEEEEE),
                                        hintText: 'Loading...',
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
                                );
                              },
                            );
                          },
                        ),
                        // StreamBuilder<DocumentSnapshot>(
                        //   stream: FirebaseFirestore.instance
                        //       .collection('events')
                        //       .doc(widget.tournamentId)
                        //       .snapshots(),
                        //   builder: (BuildContext context,
                        //       AsyncSnapshot<DocumentSnapshot> snapshot) {
                        //     if (snapshot.hasError) {
                        //       return Text('Error: ${snapshot.error}');
                        //     }

                        //     if (snapshot.connectionState ==
                        //         ConnectionState.waiting) {
                        //       return DropdownButtonFormField<String>(
                        //         items: [],
                        //         onChanged: null,
                        //         decoration: InputDecoration(
                        //           filled: true,
                        //           fillColor: Color(0xffEEEEEE),
                        //           hintText: 'Loading...',
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
                        //         ),
                        //       );
                        //     }

                        //     if (!snapshot.hasData || !snapshot.data!.exists) {
                        //       return Text('No referees data available');
                        //     }

                        //     final refereesData = snapshot.data!.get('referres');
                        //     List<String> referees = [];

                        //     if (refereesData is List<dynamic>) {
                        //       referees = refereesData.cast<String>();
                        //     } else if (refereesData is String) {
                        //       referees = refereesData
                        //           .substring(1, refereesData.length - 1)
                        //           .split(',')
                        //           .map((s) => s.trim())
                        //           .toList();
                        //     }

                        //     return Container(
                        //       padding: EdgeInsets.symmetric(horizontal: 10),
                        //       decoration: BoxDecoration(
                        //         color: Color(0xffEEEEEE),
                        //         borderRadius: BorderRadius.circular(4),
                        //         border: Border.all(
                        //           color: Color(0xffEEEEEE),
                        //           width: 0.5,
                        //         ),
                        //       ),
                        //       child: DropdownButtonHideUnderline(
                        //         child: DropdownButtonFormField<String>(
                        //           value: widget.referee,
                        //           onChanged: (String? newValue) {
                        //             setState(() {
                        //               widget.referee = newValue!;
                        //             });
                        //           },
                        //           items: referees.map((String ref) {
                        //             return DropdownMenuItem<String>(
                        //               value: ref,
                        //               child: Text(ref),
                        //             );
                        //           }).toList(),
                        //           decoration: InputDecoration(
                        //             border: InputBorder.none,
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                      ),
                    ],
                  )
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
                    updateMatch(_selectedTime!);
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
