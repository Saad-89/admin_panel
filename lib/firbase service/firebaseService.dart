import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  Future<String> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      print('Error signing up: $e');
      return '';
    }
  }

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      print('Error signing in: $e');
      return '';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> storeAdminInfo(String adminId, String name, String email) async {
    try {
      await _firestore.collection('admins').doc(adminId).set(
          {'adminId': adminId, 'name': name, 'email': email, 'role': 'admin'});
      print('Admin information stored successfully.');
    } catch (e) {
      print('Error storing admin information: $e');
    }
  }

  // storing event information to firbase firestore
  Future<void> storeEventIf(String adminId, String name, String date,
      String venue, String teams, String referres) async {
    try {
      await _firestore.collection('events').doc(adminId).set({
        'adminId': adminId,
        'name': name,
        'date': date,
        'venue': venue,
        'teams': teams,
        'referres': referres
      });
      print('Event information stored successfully.');
    } catch (e) {
      print('Error storing Enevt information: $e');
    }
  }

  Future<int> getTournamentsDocumentCount() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('adminId', isEqualTo: user!.uid)
          .get();
      int count = snapshot.size;
      return count;
    } catch (e) {
      print('Error fetching document count: $e');
      return 0;
    }
  }

  // check if current user is admin.
  Future<bool> checkUserRole(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('admins').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String role = data['role'];
        return (role == 'admin');
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
    return false;
  }

  //..............................

  Future<int> getDocumentCount(String collectionName) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();
    return querySnapshot.size;
  }

  Future<int> getMatchesCountForTournament(String tournamentId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('matchSchedule')
        .doc(tournamentId)
        .collection('matches')
        .get();
    return querySnapshot.size;
  }

  Future<int> getTeamsCountForTournament(String tournamentId) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('teams').get();
    return querySnapshot.docs.length;
  }

  Future<int> getAnnouncementsCount(String tournamentId) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('announcements').get();
    return querySnapshot.docs.length;
  }

  Future<int> getTotalMatchesCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collectionGroup('matches').get();
    return querySnapshot.size;
  }

  Future<int> getTotalTeamsCount() async {
    QuerySnapshot teamsCollectionSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    int totalTeamsCount = 0;

    for (QueryDocumentSnapshot teamDoc in teamsCollectionSnapshot.docs) {
      QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamDoc.id)
          .collection('teams')
          .get();

      totalTeamsCount += subcollectionSnapshot.size;
    }

    return totalTeamsCount;
  }

  Future<List<String>> getTournamentIds() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    List<String> tournamentIds =
        querySnapshot.docs.map((doc) => doc.id).toList();
    return tournamentIds;
  }

  Future<int> getRefereesCount() async {
    QuerySnapshot refereesSnapshot =
        await _firestore.collection('referees').get();
    return refereesSnapshot.docs.length;
  }

  Future<int> getPendingRequestsCount() async {
    QuerySnapshot requestsSnapshot = await _firestore
        .collection('requestToJoin')
        .where('status', isEqualTo: 'pending')
        .get();
    return requestsSnapshot.docs.length;
  }
}
