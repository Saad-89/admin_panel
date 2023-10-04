import 'package:admin_panel/widgets/tournaments/editTournamentDialog.dart';
import 'package:admin_panel/widgets/tournaments/organizeTournament.dart';
import 'package:admin_panel/widgets/tournaments/tournamentPreview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
User? user = FirebaseAuth.instance.currentUser;

class Tournament {
  final String? id;
  final String name;
  final String date;
  final String venue;
  final String teams;
  final List<String>? referres; // Changed to List<String>
  final List<String>? refereeNames;
  final String? tournamentLogo;
  final List<String>? refereesDocIds;

  Tournament(
      {this.id,
      required this.name,
      required this.date,
      required this.venue,
      required this.teams,
      this.referres,
      this.refereeNames,
      this.refereesDocIds,
      this.tournamentLogo});
}

class TournamentsScreen extends StatefulWidget {
  @override
  _TournamentsScreenState createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  Stream<List<Tournament>> fetchTournamentsStream() async* {
    await for (var snapshot in firestore.collection('events').snapshots()) {
      List<Tournament> tournaments = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data != null) {
          var tournamentData = data as Map<String, dynamic>;

          List<String> refereeNames = [];
          if (tournamentData['refereesDocIds'] != null) {
            for (String refId
                in List<String>.from(tournamentData['refereesDocIds'])) {
              DocumentSnapshot refereeDoc =
                  await firestore.collection('referees').doc(refId).get();
              var refData = refereeDoc.data();
              if (refData != null) {
                var refereeDetail = refData as Map<String, dynamic>;
                refereeNames.add(refereeDetail['name'] as String);
              }
            }
          }

          tournaments.add(
            Tournament(
              id: doc.id,
              name: tournamentData['name'] as String? ?? '',
              date: tournamentData['date'] as String? ?? '',
              venue: tournamentData['venue'] as String? ?? '',
              teams: tournamentData['teams'] as String? ?? '',
              referres: List<String>.from(tournamentData['referres'] ?? []),
              refereeNames: refereeNames,
              tournamentLogo: tournamentData['tournamentLogo'] as String? ?? '',
              refereesDocIds: tournamentData['refereesDocIds'] != null
                  ? List<String>.from(doc['refereesDocIds'])
                  : [],
            ),
          );
        }
      }

      yield tournaments;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Tournaments',
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
                          _openOrganizeTournamentPage(context);
                        },
                        child: Text(
                          'Create New',
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
              height: 8,
            ),
            StreamBuilder<List<Tournament>>(
              stream: fetchTournamentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: Colors.deepPurpleAccent));
                }

                if (snapshot.hasError) {
                  return Text('Error fetching tournaments');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No tournaments available'),
                      ],
                    ),
                  );
                }

                List<Tournament> tournaments = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: tournaments.length,
                    itemBuilder: (context, index) {
                      final tournament = tournaments[index];
                      return _buildTournamentCard(
                          tournament,
                          tournament
                              .id!); // Assuming the ID is non-nullable. If it is nullable, handle it appropriately.
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament, String tournamentId) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_volleyball,
                  size: 26,
                  color: Color(0xffFFA626),
                ),
                SizedBox(width: 10), // Gap between icon and text
                Expanded(
                    child: Text(tournament.name,
                        style: TextStyle(
                            color: Color(0xffFFA626),
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            SizedBox(height: 10),
            _dataRow(Icons.calendar_today, '${tournament.date}'),
            SizedBox(height: 10),
            _dataRow(Icons.place, '${tournament.venue}'),
            SizedBox(height: 10),
            _dataRow(Icons.group, '${tournament.teams}'),
            SizedBox(height: 10),
            // _dataRow(Icons.person, '${tournament.referres}'),
            _dataRow(
                Icons.person, '${tournament.refereeNames?.join(', ') ?? ''}'),

            SizedBox(height: 10),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _openTournamentPreviewPage(
                        context, tournament, tournamentId);
                  },
                  child: Text('View Details',
                      style: TextStyle(color: Color(0xffFFA626))),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    _editTournament(tournament);
                  },
                  child:
                      Text('Edit', style: TextStyle(color: Color(0xffFFA626))),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    _deleteTournament(tournament);
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Color(0xffFFA626)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _dataRow(IconData iconData, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          iconData,
          size: 26,
          color: Color(0xffFFA626),
        ),
        SizedBox(width: 10), // Gap between icon and text
        Expanded(
          child: Text(
            data,
            style: TextStyle(color: Color(0xff2D2D2D)),
          ),
        ),
      ],
    );
  }

  // Future<void> _deleteTornament(Tournament tournament) async {
  //   try {
  //     print(tournament.id);
  //     await firestore.collection('events').doc(tournament.id).delete();
  //     // Show a success message or perform any additional actions after deletion.
  //     print('tournament is deleted!');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Tournament Deleted Successfully'),
  //         backgroundColor: Colors.red,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error deleting events: $e');
  //     // Handle errors if any.
  //   }
  // }

  Future<void> _deleteTournament(Tournament tournament) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this tournament?'),
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
      try {
        print(tournament.id);

        // Delete matches associated with the tournament from matchSchedule collection
        QuerySnapshot matchesSnapshot = await firestore
            .collection('matchSchedule')
            .doc(tournament
                .id) // Assuming tournament.id corresponds to the tournament in matchSchedule
            .collection('matches')
            .get();

        for (QueryDocumentSnapshot matchDoc in matchesSnapshot.docs) {
          await matchDoc.reference.delete();
        }

        // Delete requests associated with the tournament from requestToJoin collection
        QuerySnapshot requestsSnapshot = await firestore
            .collection('requestToJoin')
            .where('tournamentId', isEqualTo: tournament.id)
            .get();

        for (QueryDocumentSnapshot requestDoc in requestsSnapshot.docs) {
          await requestDoc.reference.delete();
        }

        // Delete tournament document from events collection
        await firestore.collection('events').doc(tournament.id).delete();

        // Show a success message or perform any additional actions after deletion.
        print('Tournament, matches, and related data are deleted!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tournament deleted successfully'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        // Handle errors...
      }
    }
  }

  Future<void> _editTournament(Tournament tournament) async {
    Tournament? editedReferee = await showDialog<Tournament>(
      context: context,
      builder: (BuildContext context) {
        return EditTournamentDialog(
          tournament: tournament,
        );
      },
    );

    // Handle the editedReferee object if it's not null (i.e., the user saved the changes)
    if (editedReferee != null) {
      // Update the referee in the Firestore or handle the data as needed
      // For example:
      print('Edited Referee Name: ${editedReferee.name}');
      print('Edited Referee Email: ${editedReferee.date}');
      // ... and so on for other fields
    }
  }

  //...................................
  void _openOrganizeTournamentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizeTournamentPage(
          onTournamentCreated: (tournament) {
            // Handle the new tournament created
          },
        ),
      ),
    );
  }

  void _openTournamentPreviewPage(
      BuildContext context, Tournament tournament, String tournamentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentPreviewPage(
          tournament: tournament,
          tournamentId: tournamentId,
        ),
      ),
    );
  }
}
