import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisputedMatchesScreen extends StatelessWidget {
  Future<void> _showScoreUpdateDialog(BuildContext context, String team1Id,
      String team2Id, String matchId, String tournamentId) async {
    int? team1Score;
    int? team2Score;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Update Scores for Team $teamId'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Team 1 Score'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  team1Score = int.tryParse(value);
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Team 2 Score'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  team2Score = int.tryParse(value);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () async {
                // Update scores in Firestore
                await FirebaseFirestore.instance
                    .collection('matchSchedule')
                    .doc(tournamentId)
                    .collection('matches')
                    .doc(matchId)
                    .collection('scores')
                    .doc(team1Id)
                    .set({
                  'team1Score': team1Score,
                  'team2Score': team2Score,
                });

                await FirebaseFirestore.instance
                    .collection('matchSchedule')
                    .doc(tournamentId)
                    .collection('matches')
                    .doc(matchId)
                    .collection('scores')
                    .doc(team2Id)
                    .set({
                  'team1Score': team1Score,
                  'team2Score': team2Score,
                });

                // update score dispute matches
                await FirebaseFirestore.instance
                    .collection('scoredispute')
                    .doc(matchId)
                    .update({
                  // 'scoresEnteredByTeam1': {
                  //   'team1Score': team1Score,
                  //   'team2Score': team2Score,
                  // },
                  // 'scoresEnteredByTeam2': {
                  //   'team1Score': team1Score,
                  //   'team2Score': team2Score,
                  // },
                  'scoresUpdated': {
                    'team1Score': team1Score,
                    'team2Score': team2Score,
                  },
                  'team1Id': team1Id,
                  'team2Id': team2Id,
                  'matchId': matchId,
                  'tournamentId': tournamentId
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> matchesStream =
        FirebaseFirestore.instance.collection('scoredispute').snapshots();

    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scores Dispute',
                    style: TextStyle(
                        fontFamily: 'karla',
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Color(0xff2D2D2D)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: matchesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> matches = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index].data() as Map<String, dynamic>;
                    return Card(
                      color: Color(0xffFFF9F0),
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text('Match ID: ${matches[index].id}'),
                            // SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Team 1'),
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('teams')
                                          .doc('${match['team1Id']}')
                                          .collection(
                                              'teams') // Adjusted for the subcollection
                                          .doc(
                                              '${match['team1Id']}') // Replace with the appropriate subcollection document ID
                                          .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              teamSnapshot) {
                                        // Check if the snapshot is still loading
                                        if (teamSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.deepPurpleAccent,
                                          )); // or some other loading indicator
                                        }

                                        // If there's an actual error in fetching the team
                                        if (teamSnapshot.hasError) {
                                          return Text(
                                              'Error: ${teamSnapshot.error}');
                                        }

                                        // If the team is not found (even after loading)
                                        if (!teamSnapshot.hasData) {
                                          return Text('Team not found.');
                                        }

                                        final teamData = teamSnapshot.data!
                                            .data() as Map<String, dynamic>;

                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Color(0xffFFA626),
                                                      width: 2),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        teamData['logo']),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '${teamData['teamName']}'
                                                    .toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'karla',
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      '${match['scoresEnteredByTeam1']['team1Score']} - ${match['scoresEnteredByTeam1']['team2Score']}',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Team 2'),
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('teams')
                                          .doc('${match['team2Id']}')
                                          .collection(
                                              'teams') // Adjusted for the subcollection
                                          .doc(
                                              '${match['team2Id']}') // Replace with the appropriate subcollection document ID
                                          .get(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              teamSnapshot) {
                                        // Check if the snapshot is still loading
                                        if (teamSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.deepPurpleAccent,
                                          )); // or some other loading indicator
                                        }

                                        // If there's an actual error in fetching the team
                                        if (teamSnapshot.hasError) {
                                          return Text(
                                              'Error: ${teamSnapshot.error}');
                                        }

                                        // If the team is not found (even after loading)
                                        if (!teamSnapshot.hasData) {
                                          return Text('Team not found.');
                                        }

                                        final teamData = teamSnapshot.data!
                                            .data() as Map<String, dynamic>;

                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Color(0xffFFA626),
                                                      width: 2),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        teamData['logo']),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                '${teamData['teamName']}'
                                                    .toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'karla',
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      '${match['scoresEnteredByTeam2']['team1Score']} - ${match['scoresEnteredByTeam2']['team2Score']}',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  match['scoresUpdated'] != null
                                      ? '${match['scoresUpdated']['team1Score']} - ${match['scoresUpdated']['team2Score']}'
                                      : '',
                                  style: TextStyle(
                                    color: match['scoresUpdated'] != null
                                        ? Colors.green
                                        : Colors.transparent,
                                    fontFamily: 'karla',
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color(0xffFFA626)),
                                  ),
                                  onPressed: () {
                                    _showScoreUpdateDialog(
                                        context,
                                        match['team1Id'],
                                        match['team2Id'],
                                        match['matchId'],
                                        match['tournamentId']);
                                  },
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'karla'),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color(0xffFFA626)),
                                  ),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('matchSchedule')
                                        .doc(match['tournamentId'])
                                        .collection('matches')
                                        .doc(match['matchId'])
                                        .delete();
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'karla'),
                                  ),
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
          ],
        ),
      ),
    );
  }
}
