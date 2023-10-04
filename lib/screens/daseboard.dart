import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../firbase service/firebaseService.dart';
import '../util/notificationService/notificationServices.dart';

FirebaseService firebaseService = FirebaseService();

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  dynamic _selectedCard;
  Map<String, int> _matchesCountMap =
      {}; // Map to store matches counts for each tournament ID
  Map<String, int> _teamsCountMap =
      {}; // Map to store teams counts for each tournament ID
  int _totalMatchesCount = 0;
  int _totalTeamsCount = 0;
  int _totalAccouncementCount = 0;

  int _refereesCount = 0;
  int _pendingRequestsCount = 0;

  // @override
  // void initState() {
  //   super.initState();

  // }

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<String> tournamentIds = await firebaseService.getTournamentIds();
    int refereesCount = await firebaseService.getRefereesCount();
    int pendingRequestsCount = await firebaseService.getPendingRequestsCount();

    for (String tournamentId in tournamentIds) {
      int matchesCount =
          await firebaseService.getMatchesCountForTournament(tournamentId);
      int teamsCount = await firebaseService.getTotalTeamsCount();

      print('teamsCount: $teamsCount');
      int announcementCounts =
          await firebaseService.getAnnouncementsCount(tournamentId);

      setState(() {
        _matchesCountMap[tournamentId] = matchesCount;
        _teamsCountMap[tournamentId] = teamsCount;
        _refereesCount = refereesCount;
        _pendingRequestsCount = pendingRequestsCount;
        _totalAccouncementCount = announcementCounts;
        _totalTeamsCount = teamsCount;
      });
    }

    // Calculate total matches and teams counts
    int totalMatches = 0;
    int totalTeams = 0;
    for (int count in _matchesCountMap.values) {
      totalMatches += count;
    }
    for (int count in _teamsCountMap.values) {
      totalTeams += count;
    }
    setState(() {
      _totalMatchesCount = totalMatches;
      // _totalTeamsCount = totalTeams;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, Admin',
                    style: TextStyle(
                        fontFamily: 'karla',
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Color(0xff2D2D2D)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 20,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Color(0xffFFA626), width: 2),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    'https://assets.materialup.com/uploads/b78ca002-cd6c-4f84-befb-c09dd9261025/preview.png')),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Mr Admin',
                          style: TextStyle(
                              fontFamily: 'karla',
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              color: Color(0xff2D2D2D)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCard(
                            icon: Icons.sports_soccer,
                            title: 'Tournaments',
                            description: '${_matchesCountMap.length}',
                            color: Color(0xffF95232),
                            iconColor: Color(0xffF95232),
                            isSelected: _selectedCard == 'Tournaments',
                            onTap: () {
                              setState(() {
                                _selectedCard = 'Tournaments';
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          _buildCard(
                            icon: Icons.sports_rounded,
                            title: 'Matches',
                            description: '$_totalMatchesCount',
                            color: Color(0xff6858FE),
                            iconColor: Color(0xff6858FE),
                            isSelected: _selectedCard == 'Matches',
                            onTap: () {
                              setState(() {
                                _selectedCard = 'Matches';
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          _buildCard(
                            icon: Icons.groups_3_sharp,
                            title: 'Teams',
                            description: '${_totalTeamsCount}',
                            color: Color(0xff2D9852),
                            iconColor: Color(0xff2D9852),
                            isSelected: _selectedCard == 'Teams',
                            onTap: () {
                              setState(() {
                                _selectedCard = 'Teams';
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCard(
                            icon: Icons.groups,
                            title: 'Referees',
                            description: '$_refereesCount',
                            color: Color(0xff2C9891),
                            iconColor: Color(0xff2C9891),
                            isSelected: _selectedCard == 'Referees',
                            onTap: () {
                              setState(() {
                                _selectedCard = 'Referees';
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          _buildCard(
                            icon: Icons.mic,
                            title: 'Announcements',
                            description: '$_totalAccouncementCount',
                            color: Color(0xffFFA626),
                            iconColor: Color(0xffFFA626),
                            isSelected: _selectedCard == 'Announcements',
                            onTap: () {
                              setState(() {
                                _selectedCard = 'Announcements';
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          _buildCard(
                            icon: Icons.group_add_rounded,
                            title: 'Team Request',
                            description: '$_pendingRequestsCount',
                            color: Color(0xffD247AB),
                            iconColor: Color(0xffD247AB),
                            isSelected: _selectedCard == 'Team Request',
                            onTap: () {
                              setState(() {
                                _selectedCard = 'Team Request';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // if (_selectedCard != null) _buildCardPreview(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String description,
    required Color color,
    required bool isSelected,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 400,
          height: 220,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.8) : color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 100,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Aligned to center
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 30,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'karla',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'karla',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCard = null;
        });
      },
      child: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      _selectedCard = null;
                    });
                  },
                ),
                SizedBox(width: 8),
                Text(
                  _selectedCard!,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'karla',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'This is the preview of $_selectedCard',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'karla',
              ),
            ),
            SizedBox(height: 16),
            if (_selectedCard == 'Matches')
              for (String tournamentId in _matchesCountMap.keys)
                Text(
                  'Matches Count for Tournament $tournamentId: ${_matchesCountMap[tournamentId]}',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'karla',
                  ),
                ),
            if (_selectedCard == 'Teams')
              for (String tournamentId in _teamsCountMap.keys)
                Text(
                  'Teams Count for Tournament $tournamentId: ${_teamsCountMap[tournamentId]}',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'karla',
                  ),
                ),
            SizedBox(height: 16),
            Text(
              'Total Matches Count: $_totalMatchesCount',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'karla',
              ),
            ),
            Text(
              'Total Teams Count: $_totalTeamsCount',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'karla',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    final baseHeight = size.height *
        0.4; // Roughly the height up to where the wave starts in the SVG
    path.moveTo(0, baseHeight);

    // 1st Curve (Crest)
    path.cubicTo(
      size.width * 0.15, baseHeight - 30, // 1st control point
      size.width * 0.3, baseHeight - 15, // 2nd control point
      size.width * 0.4, baseHeight, // End point
    );

    // 2nd Curve (Trough)
    path.cubicTo(
      size.width * 0.5, baseHeight + 15, // 1st control point
      size.width * 0.6, baseHeight + 10, // 2nd control point
      size.width * 0.7, baseHeight, // End point
    );

    // 3rd Curve (Crest)
    path.cubicTo(
      size.width * 0.8, baseHeight - 15, // 1st control point
      size.width * 0.9, baseHeight - 10, // 2nd control point
      size.width, baseHeight, // End point
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
