import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin panel/adminPanel.dart';
import 'screens/signUpScreen.dart';
import 'util/userSession.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyAJa877I96X5xZ-4I9a0QWZ0AXMle71sC0",
    projectId: "tournament-organization-app",
    messagingSenderId: "335056842960",
    appId: "1:335056842960:web:81c34bfdc0e5002cb8aed5",
    storageBucket: "tournament-organization-app.appspot.com",
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    UserSession usersession = UserSession();
    String? storedUserId = usersession.getUserSession();

    Widget homePage;
    if (storedUserId != null) {
      // User is already logged in, navigate to the home page
      homePage = AdminPanel();
    } else {
      // User is not logged in, navigate to the sign-up page
      homePage = SignUpScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homePage,
    );
  }
}





  // SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         StreamBuilder<QuerySnapshot>(
  //           stream:
  //               FirebaseFirestore.instance.collection('captains').snapshots(),
  //           builder: (context, snapshot) {
  //             if (snapshot.hasError)
  //               return Text('Error fetching captains: ${snapshot.error}');
  //             if (snapshot.connectionState == ConnectionState.waiting)
  //               return CircularProgressIndicator();
  //             final captains = snapshot.data!.docs;
  //             return Column(
  //               children: [
  //                 Expanded(
  //                   child: ListView.builder(
  //                     shrinkWrap: true,
  //                     physics: NeverScrollableScrollPhysics(),
  //                     itemCount: captains.length,
  //                     itemBuilder: (context, index) {
  //                       return StreamBuilder<QuerySnapshot>(
  //                         stream: FirebaseFirestore.instance
  //                             .collection('teams')
  //                             .doc(captains[index].id)
  //                             .collection('teams')
  //                             .where('createdBy', isEqualTo: 'admin')
  //                             .snapshots(),
  //                         builder: (context, teamSnapshot) {
  //                           if (teamSnapshot.hasError)
  //                             return Text(
  //                                 'Error fetching teams: ${teamSnapshot.error}');
  //                           if (teamSnapshot.connectionState ==
  //                               ConnectionState.waiting)
  //                             return CircularProgressIndicator();

  //                           if (!teamSnapshot.hasData ||
  //                               teamSnapshot.data!.docs.isEmpty) {
  //                             return Text(
  //                                 "No teams found for ${captains[index]['name']}.");
  //                           }

  //                           final teams = teamSnapshot.data!.docs;

  //                           // Now, render your GridView (or any other widget) using these teams.
  //                           return Column(
  //                             children: [
  //                               GridView.builder(
  //                                 shrinkWrap: true,
  //                                 physics: NeverScrollableScrollPhysics(),
  //                                 gridDelegate:
  //                                     SliverGridDelegateWithFixedCrossAxisCount(
  //                                   crossAxisCount: 3,
  //                                   mainAxisSpacing: 4.0,
  //                                   crossAxisSpacing: 4.0,
  //                                   childAspectRatio: 0.9,
  //                                 ),
  //                                 itemCount: teams.length,
  //                                 itemBuilder: (context, teamIndex) {
  //                                   final teamData = teams[teamIndex].data()
  //                                       as Map<String, dynamic>;
  //                                   final teamLogo = teamData['logo'];

  //                                   Card(
  //                                     color: Color(0xffF3F2FF),
  //                                     elevation: 2,
  //                                     shape: RoundedRectangleBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(10)),
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.center,
  //                                       children: [
  //                                         Container(
  //                                           width: 70,
  //                                           height: 70,
  //                                           decoration: BoxDecoration(
  //                                             borderRadius:
  //                                                 BorderRadius.circular(10),
  //                                             border: Border.all(
  //                                                 color: Color(0xffFFA626),
  //                                                 width: 2),
  //                                             image: DecorationImage(
  //                                                 fit: BoxFit.cover,
  //                                                 image: NetworkImage(
  //                                                     '$teamLogo')),
  //                                           ),
  //                                         ),
  //                                         SizedBox(height: 10),
  //                                         Text(teamData['teamName'],
  //                                             style: TextStyle(
  //                                                 fontFamily: 'karla',
  //                                                 fontSize: 26,
  //                                                 fontWeight: FontWeight.bold)),
  //                                         SizedBox(height: 10),
  //                                         Text(teamData['captainname'],
  //                                             style: TextStyle(
  //                                               fontFamily: 'karla',
  //                                               fontSize: 16,
  //                                             )),
  //                                         SizedBox(height: 10),
  //                                         Text(teamData['tagline'],
  //                                             style: TextStyle(
  //                                               fontFamily: 'karla',
  //                                               fontSize: 16,
  //                                             )),
  //                                         SizedBox(height: 10),
  //                                         Text(teamData['clubName'],
  //                                             style: TextStyle(
  //                                                 fontFamily: 'karla',
  //                                                 fontSize: 18,
  //                                                 fontWeight: FontWeight.w500,
  //                                                 color: Color(0xffFFA626))),
  //                                         SizedBox(height: 10),
  //                                         Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.center,
  //                                           children: [
  //                                             TextButton(
  //                                               onPressed: () {
  //                                                 _showEditDialog(
  //                                                     context, teams[index]);
  //                                               },
  //                                               child: Text("Edit",
  //                                                   style: TextStyle(
  //                                                     color: Color(0xff6858FE),
  //                                                     fontSize: 18,
  //                                                   )),
  //                                             ),
  //                                             TextButton(
  //                                               onPressed: () {
  //                                                 // This will delete the selected team
  //                                                 FirebaseFirestore.instance
  //                                                     .doc(teams[index]
  //                                                         .reference
  //                                                         .path)
  //                                                     .delete();
  //                                               },
  //                                               child: Text(
  //                                                 "Delete",
  //                                                 style: TextStyle(
  //                                                   color: Color(0xff6858FE),
  //                                                   fontSize: 18,
  //                                                 ),
  //                                               ),
  //                                             )
  //                                           ],
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             ],
  //                           );
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );