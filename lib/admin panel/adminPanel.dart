import 'package:admin_panel/screens/news.dart';
import 'package:flutter/material.dart';
import '../screens/announcments.dart';
import '../screens/daseboard.dart';
import '../screens/refrees.dart';
import '../screens/scoredispute.dart';
import '../screens/tournament.dart';
import '../screens/teams.dart';

class AdminPanel extends StatefulWidget {
  final String? selectedMenu;

  AdminPanel({this.selectedMenu});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String _selectedMenu = 'D A S H B O A R D'; // Default selected menu
  final ValueNotifier<String?> hoveredMenuNotifier =
      ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    if (widget.selectedMenu != null) {
      _selectedMenu = widget.selectedMenu!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Container(
              width: 300.0,
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                        height: 20,
                      ),
                      Container(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMenuItem('D A S H B O A R D'),
                            SizedBox(
                              height: 20,
                            ),
                            _buildMenuItem('T O U R N A M E N T S'),
                            SizedBox(
                              height: 20,
                            ),
                            _buildMenuItem('R E F E R E E S'),
                            SizedBox(
                              height: 20,
                            ),
                            _buildMenuItem('T E A M S'),
                            SizedBox(
                              height: 20,
                            ),
                            _buildMenuItem('N E W S'),
                            SizedBox(
                              height: 20,
                            ),
                            _buildMenuItem('S C O R E S'),
                            SizedBox(
                              height: 20,
                            ),
                            _buildMenuItem('A N N O U N C E'),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xffF5F5F5),
              child: _buildScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String menuName) {
    bool isSelected = _selectedMenu == menuName;

    // Default icon initialization
    Icon menuIcon = Icon(Icons.menu,
        color: isSelected ? Color(0xffFFA626) : Color(0xff9D9D9D));

    // Assign icons based on menuName
    switch (menuName) {
      case 'D A S H B O A R D':
        menuIcon = Icon(Icons.dashboard,
            color: isSelected ? Color(0xffFFA626) : Color(0xff9D9D9D));
        break;
      case 'T O U R N A M E N T S':
        menuIcon = Icon(Icons.sports_soccer,
            color: isSelected ? Color(0xffFFA626) : Color(0xff9D9D9D));
        break;
      case 'R E F E R E E S':
        menuIcon = Icon(Icons.groups,
            color: isSelected ? Color(0xffFFA626) : Color(0xff9D9D9D));
        break;
      case 'T E A M S':
        menuIcon = Icon(Icons.groups,
            color: isSelected ? Color(0xffFFA626) : Color(0xff9D9D9D));
        break;
      case 'N E W S':
        menuIcon = Icon(Icons.newspaper,
            color: isSelected ? Color(0xffFFA626) : Color(0xff9D9D9D));
        break;
      case 'S C O R E S':
        menuIcon = Icon(Icons.scoreboard,
            color: isSelected ? Color(0xffFFA626) : Color(0xff9D9D9D));
        break;
      case 'A N N O U N C E':
        menuIcon = Icon(Icons.announcement_rounded,
            color: isSelected ? Color(0xffFFA626) : Color(0xff9D9D9D));
        break;
    }

    return MouseRegion(
      onEnter: (_) {
        hoveredMenuNotifier.value = menuName;
      },
      onExit: (_) {
        hoveredMenuNotifier.value = null;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedMenu = menuName;
            });
          },
          borderRadius: BorderRadius.circular(20.0),
          child: ValueListenableBuilder<String?>(
            valueListenable: hoveredMenuNotifier,
            builder: (context, hoveredMenu, _) {
              bool isHovered = hoveredMenu == menuName;

              return Container(
                decoration: isSelected
                    ? BoxDecoration(
                        border: Border.all(color: Color(0xffFFA626)),
                        borderRadius: BorderRadius.circular(20.0),
                      )
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    menuIcon,
                    SizedBox(width: 10),
                    Text(
                      menuName,
                      style: TextStyle(
                        fontFamily: 'karla',
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Color(0xff2D2D2D) : Color(0xff9D9D9D),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_selectedMenu) {
      case 'D A S H B O A R D':
        return DashboardScreen();
      case 'T O U R N A M E N T S':
        return TournamentsScreen();
      case 'R E F E R E E S':
        return RefereesScreen();
      case 'T E A M S':
        return TeamScreen();
      case 'N E W S':
        return NewsScreen();
      case 'S C O R E S':
        return DisputedMatchesScreen();
      case 'A N N O U N C E':
        return AnnouncementScreen();
      default:
        return Container();
    }
  }
}
