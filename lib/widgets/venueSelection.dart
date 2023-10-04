// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class VenueBox extends StatefulWidget {
//   final String? id;

//   VenueBox({this.id});

//   @override
//   _VenueBoxState createState() => _VenueBoxState();
// }

// class _VenueBoxState extends State<VenueBox> {
//   bool locationPicked = false;
//   String? venueName;

//   void _showVenueInputDialog(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VenueDetailsPage(
//           venueName: venueName,
//           id: widget.id,
//           selectedLocation: locationPicked ? LatLng(1.3521, 103.8198) : null,
//           onVenueSelected: (String? name, LatLng? location) {
//             if (name != null && location != null) {
//               setState(() {
//                 venueName = name;
//                 locationPicked = true;
//               });
//             }
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _showVenueInputDialog(context);
//       },
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Color(0xff6858FE),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: Offset(0, 3), // changes the position of the shadow
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.location_on, color: Colors.white),
//             SizedBox(width: 10),
//             Text(
//               venueName ?? 'Select Tournament Venue',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             Spacer(),
//             Icon(Icons.arrow_forward_ios, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // venue details google map select veue......

// class VenueDetailsPage extends StatefulWidget {
//   final String? venueName;
//   final String? id;
//   final LatLng? selectedLocation;

//   final Function(String? name, LatLng? location) onVenueSelected;

//   VenueDetailsPage(
//       {required this.venueName,
//       required this.selectedLocation,
//       required this.onVenueSelected,
//       required this.id});

//   @override
//   VenueDetailsPageState createState() => VenueDetailsPageState();
// }

// class VenueDetailsPageState extends State<VenueDetailsPage> {
//   List<dynamic> suggestions = [];
//   GoogleMapController? _mapController;
//   LocationData? _currentLocation;
//   String? _localVenueName;
//   LatLng? _selectedLocation;

//   TextEditingController _searchController = TextEditingController();
//   bool _isMapLoaded = false; // Track if the map is loaded

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _localVenueName = widget.venueName;
//     _selectedLocation = widget.selectedLocation;
//     _searchController.text = _localVenueName ?? '';
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('the id we have in venue detail page ${widget.id}');
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: Icon(Icons.arrow_back_sharp)),
//                 SizedBox(
//                   width: 40,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Club',
//                       style: TextStyle(
//                           fontSize: 34,
//                           color: Color(0xff6858FE),
//                           fontFamily: 'karla',
//                           fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       'Match',
//                       style: TextStyle(
//                           fontSize: 34,
//                           color: Color(0xffFFA626),
//                           fontFamily: 'karla',
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search for a location...',
//                       filled: true,
//                       fillColor: Color(0xffEEEEEE),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 15,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       _getSuggestions(value);
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     height: 40,
//                     decoration:
//                         BoxDecoration(borderRadius: BorderRadius.circular(15)),
//                     child: ElevatedButton(
//                       style: ButtonStyle(
//                           shape: MaterialStatePropertyAll(
//                               RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15))),
//                           backgroundColor: MaterialStatePropertyAll(
//                               Colors.deepPurpleAccent)),
//                       onPressed: () {
//                         widget.onVenueSelected(
//                             _localVenueName, _selectedLocation);

//                         print('Venue Name: $_localVenueName');
//                         print('Latitude: ${_selectedLocation?.latitude}');
//                         print('Longitude: ${_selectedLocation?.longitude}');
//                         print('Longitude: ${_selectedLocation}');
//                         FirebaseFirestore.instance
//                             .collection('events')
//                             .doc(widget.id)
//                             .set({
//                           'venue': _localVenueName,
//                           'lat': _selectedLocation?.latitude,
//                           'lng': _selectedLocation?.longitude
//                         });

//                         Navigator.pop(
//                           context,
//                         );
//                       },
//                       child: Text('Submit'),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: _selectedLocation ?? LatLng(1.3521, 103.8198),
//                     zoom: 15,
//                   ),
//                   onMapCreated: (controller) {
//                     _mapController = controller;
//                     _moveToSelectedLocation();
//                   },
//                   markers: {
//                     if (_currentLocation != null)
//                       Marker(
//                         markerId: MarkerId('currentLocation'),
//                         position: LatLng(
//                           _currentLocation!.latitude!,
//                           _currentLocation!.longitude!,
//                         ),
//                         infoWindow: InfoWindow(title: 'Current Location'),
//                       ),
//                     if (_selectedLocation != null)
//                       Marker(
//                         markerId: MarkerId('selectedLocation'),
//                         position: _selectedLocation!,
//                         infoWindow: InfoWindow(title: _localVenueName!),
//                       ),
//                   },
//                 ),

//                 // GoogleMap(
//                 //   initialCameraPosition: CameraPosition(
//                 //     target: _selectedLocation ?? LatLng(1.3521, 103.8198),
//                 //     zoom: 15,
//                 //   ),
//                 //   onMapCreated: (controller) {
//                 //     _mapController = controller;
//                 //     _moveToSelectedLocation();
//                 //   },
//                 //   markers: {
//                 //     if (_currentLocation != null)
//                 //       Marker(
//                 //         markerId: MarkerId('currentLocation'),
//                 //         position: LatLng(
//                 //           _currentLocation!.latitude!,
//                 //           _currentLocation!.longitude!,
//                 //         ),
//                 //         infoWindow: InfoWindow(title: 'Current Location'),
//                 //       ),
//                 //     if (_selectedLocation != null)
//                 //       Marker(
//                 //         markerId: MarkerId('selectedLocation'),
//                 //         position: _selectedLocation!,
//                 //         infoWindow: InfoWindow(title: _localVenueName!),
//                 //       ),
//                 //   },
//                 // ),
//                 if (suggestions.isNotEmpty)
//                   Positioned(
//                     top: 10, // Add top positioning to your preference
//                     left: 20,
//                     right: 20,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       height: 200, // Adjust based on your needs
//                       child: _buildSuggestionsList(),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           // Expanded(
//           //   child: Container(
//           //     child: GoogleMap(
//           //       initialCameraPosition: CameraPosition(
//           //         target: _selectedLocation ?? LatLng(1.3521, 103.8198),
//           //         zoom: 15,
//           //       ),
//           //       onMapCreated: (controller) {
//           //         _mapController = controller;
//           //         _moveToSelectedLocation();
//           //       },
//           //       markers: {
//           //         if (_currentLocation != null)
//           //           Marker(
//           //             markerId: MarkerId('currentLocation'),
//           //             position: LatLng(
//           //               _currentLocation!.latitude!,
//           //               _currentLocation!.longitude!,
//           //             ),
//           //             infoWindow: InfoWindow(title: 'Current Location'),
//           //           ),
//           //         if (_selectedLocation != null)
//           //           Marker(
//           //             markerId: MarkerId('selectedLocation'),
//           //             position: _selectedLocation!,
//           //             infoWindow: InfoWindow(title: _localVenueName!),
//           //           ),
//           //       },
//           //     ),
//           //   ),
//           // )
//         ],
//       ),
//     );
//   }

//   Future<void> _getCurrentLocation() async {
//     Location location = Location();
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;
//     LocationData locationData;

//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         return;
//       }
//     }

//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     locationData = await location.getLocation();
//     setState(() {
//       _currentLocation = locationData;
//     });

//     if (_mapController != null) {
//       _mapController!.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(locationData.latitude!, locationData.longitude!),
//             zoom: 15,
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> _getSuggestions(String input) async {
//     String KPLACES_API_KEY = 'AIzaSyBMfLAQ0VJVMikgS7RsJz5pGmDVd6Dt6lE';
//     // String baseURL ='https://maps.googleapis.com/maps/api/place/autocomplete/json';
//     String baseURL =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json';

//     // String baseURL = 'http://localhost:5000/places/autocomplete';
//     String request = '$baseURL?input=$input&key=$KPLACES_API_KEY';

//     var response = await http.get(Uri.parse(request));
//     if (response.statusCode == 200) {
//       setState(() {
//         suggestions =
//             json.decode(response.body)['predictions'] as List<dynamic>;
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   Widget _buildSuggestionsList() {
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final location = suggestions[index]['description'];
//         return ListTile(
//           onTap: () async {
//             _searchController.text = location;
//             String placeId = suggestions[index]['place_id'];
//             LatLng? selectedLocation = await _getSelectedLocation(placeId);
//             if (selectedLocation != null) {
//               setState(() {
//                 _localVenueName = location;
//                 _selectedLocation = selectedLocation;
//                 _moveToSelectedLocation();
//                 suggestions.clear(); // This will clear the suggestions list
//               });
//             }
//           },
//           title: Text(location),
//         );
//       },
//     );
//   }

//   // Widget _buildSuggestionsList() {
//   //   return ListView.builder(
//   //     itemCount: suggestions.length,
//   //     itemBuilder: (context, index) {
//   //       final location = suggestions[index]['description'];
//   //       return ListTile(
//   //         onTap: () async {
//   //           _searchController.text = location;
//   //           String placeId = suggestions[index]['place_id'];
//   //           LatLng? selectedLocation = await _getSelectedLocation(placeId);
//   //           if (selectedLocation != null) {
//   //             setState(() {
//   //               _localVenueName = location;
//   //               _selectedLocation = selectedLocation;
//   //               _moveToSelectedLocation();
//   //             });
//   //           }
//   //         },
//   //         title: Text(location),
//   //       );
//   //     },
//   //   );
//   // }

//   Future<LatLng?> _getSelectedLocation(String placeId) async {
//     String KPLACES_API_KEY = 'AIzaSyBMfLAQ0VJVMikgS7RsJz5pGmDVd6Dt6lE';
//     String baseURL = 'https:///maps.googleapis.com/maps/api/place/details/json';
//     // String baseURL = 'http://localhost:3000/places/details';
//     String request =
//         '$baseURL?place_id=$placeId&fields=geometry&key=$KPLACES_API_KEY';

//     var response = await http.get(Uri.parse(request));
//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);
//       if (data['status'] == 'OK') {
//         var lat = data['result']['geometry']['location']['lat'];
//         var lng = data['result']['geometry']['location']['lng'];
//         print('LatLng: $lat $lng');
//         return LatLng(lat, lng);
//       }
//     }
//     return null;
//   }

//   // Future<LatLng?> _getSelectedLocation(String placeId) async {
//   //   // String baseURL = 'http://localhost:3000/places/details';
//   //   String baseURL = 'https:///maps.googleapis.com/maps/api/place/details/json';
//   //   String request = '$baseURL?placeId=$placeId';

//   //   var response = await http.get(Uri.parse(request));
//   //   if (response.statusCode == 200) {
//   //     var data = json.decode(response.body);
//   //     if (data['lat'] != null && data['lng'] != null) {
//   //       var lat = data['lat'];
//   //       var lng = data['lng'];
//   //       print('LatLng: $lat $lng');
//   //       return LatLng(lat, lng);
//   //     }
//   //   }
//   //   return null;
//   // }

//   void _moveToSelectedLocation() {
//     if (_mapController != null && _selectedLocation != null) {
//       _mapController!.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: _selectedLocation!,
//             zoom: 15,
//           ),
//         ),
//       );
//     }
//   }
// }

//  // Expanded(
//           //   flex: 1,
//           //   child: Container(
//           //     padding: EdgeInsets.all(16),
//           //     decoration: BoxDecoration(
//           //       color: Colors.white,
//           //       borderRadius: BorderRadius.only(
//           //         topLeft: Radius.circular(20),
//           //         topRight: Radius.circular(20),
//           //       ),
//           //       boxShadow: [
//           //         BoxShadow(
//           //           color: Colors.grey.withOpacity(0.5),
//           //           spreadRadius: 2,
//           //           blurRadius: 5,
//           //           offset: Offset(0, 3),
//           //         ),
//           //       ],
//           //     ),
//           //     child: Column(
//           //       mainAxisSize: MainAxisSize.min,
//           //       children: [
//           //         TextField(
//           //           controller: _searchController,
//           //           decoration: InputDecoration(
//           //             hintText: 'Search for a location...',
//           //             filled: true,
//           //             fillColor: Colors.grey[200],
//           //             border: OutlineInputBorder(
//           //               borderRadius: BorderRadius.circular(30),
//           //               borderSide: BorderSide.none,
//           //             ),
//           //             contentPadding: EdgeInsets.symmetric(
//           //               horizontal: 20,
//           //               vertical: 15,
//           //             ),
//           //           ),
//           //           onChanged: (value) {
//           //             _getSuggestions(value);
//           //           },
//           //         ),
//           //         SizedBox(height: 20),
//           //         Expanded(
//           //           child: _buildSuggestionsList(),
//           //         ),
//           //         // ElevatedButton(
//           //         //   style: ButtonStyle(
//           //         //       backgroundColor:
//           //         //           MaterialStatePropertyAll(Colors.deepPurpleAccent)),
//           //         //   onPressed: () {
//           //         //     widget.onVenueSelected(
//           //         //         _localVenueName, _selectedLocation);

//           //         //     print('Venue Name: $_localVenueName');
//           //         //     print('Latitude: ${_selectedLocation?.latitude}');
//           //         //     print('Longitude: ${_selectedLocation?.longitude}');
//           //         //     print('Longitude: ${_selectedLocation}');
//           //         //     FirebaseFirestore.instance
//           //         //         .collection('events')
//           //         //         .doc(widget.id)
//           //         //         .set({
//           //         //       'venue': _localVenueName,
//           //         //       'lat': _selectedLocation?.latitude,
//           //         //       'lng': _selectedLocation?.longitude
//           //         //     });

//           //         //     // Create a map to hold the data you want to pass back
//           //         //     // Map<String, dynamic> resultData = {
//           //         //     //   'VenueName': _localVenueName,
//           //         //     //   'selectedLocation': _selectedLocation,
//           //         //     // };
//           //         //     Navigator.pop(
//           //         //       context,
//           //         //     );
//           //         //   },
//           //         //   child: Text('Submit'),
//           //         // ),
//           //       ],
//           //     ),
//           //   ),
//           // ),

import 'dart:ui' as ui;
import 'dart:js' as js;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VenueBox extends StatefulWidget {
  final String? id;

  VenueBox({this.id});

  @override
  _VenueBoxState createState() => _VenueBoxState();
}

class _VenueBoxState extends State<VenueBox> {
  bool locationPicked = false;
  String? venueName;

  void _showVenueInputDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VenueDetailsPage(
          venueName: venueName,
          id: widget.id,
          selectedLocation: locationPicked ? LatLng(1.3521, 103.8198) : null,
          onVenueSelected: (String? name, LatLng? location) {
            if (name != null && location != null) {
              setState(() {
                venueName = name;
                locationPicked = true;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showVenueInputDialog(context);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xff6858FE),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white),
            SizedBox(width: 10),
            Text(
              venueName ?? 'Select Tournament Venue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class VenueDetailsPage extends StatefulWidget {
  final String? venueName;
  final String? id;
  final LatLng? selectedLocation;
  final Function(String? name, LatLng? location) onVenueSelected;

  VenueDetailsPage(
      {required this.venueName,
      required this.selectedLocation,
      required this.onVenueSelected,
      required this.id});

  @override
  VenueDetailsPageState createState() => VenueDetailsPageState();
}

class VenueDetailsPageState extends State<VenueDetailsPage> {
  List<String> suggestions = [];
  GoogleMapController? _mapController;
  LatLng? _localVenueName;
  LatLng? _selectedLocation;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localVenueName = widget.selectedLocation;
    _selectedLocation = widget.selectedLocation;
    _searchController.text = widget.venueName ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_sharp)),
                SizedBox(width: 40),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Club',
                      style: TextStyle(
                          fontSize: 34,
                          color: Color(0xff6858FE),
                          fontFamily: 'karla',
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  Text('Match',
                      style: TextStyle(
                          fontSize: 34,
                          color: Color(0xffFFA626),
                          fontFamily: 'karla',
                          fontWeight: FontWeight.bold)),
                ]),
                SizedBox(width: 30),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a location...',
                      filled: true,
                      fillColor: Color(0xffEEEEEE),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onChanged: (value) => _getSuggestions(value),
                  ),
                ),
                SizedBox(width: 30),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 40,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.deepPurpleAccent)),
                      onPressed: () {
                        widget.onVenueSelected(
                            _searchController.text, _selectedLocation);
                        FirebaseFirestore.instance
                            .collection('events')
                            .doc(widget.id)
                            .set({
                          'venue': _searchController.text,
                          'lat': _selectedLocation?.latitude,
                          'lng': _selectedLocation?.longitude,
                        });
                        Navigator.pop(
                          context,
                        );
                      },
                      child: Text('Submit'),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? LatLng(1.3521, 103.8198),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: {
                    if (_selectedLocation != null)
                      Marker(
                          markerId: MarkerId('selectedLocation'),
                          position: _selectedLocation!,
                          infoWindow:
                              InfoWindow(title: _localVenueName.toString())),
                  },
                ),
                if (suggestions.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 20,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      height: 200,
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final location = suggestions[index];
                          return ListTile(
                            title: Text(location),
                            onTap: () async {
                              final latLng = await _getLatLngFromName(location);
                              _setMapLocation(latLng, location);
                              setState(() {
                                suggestions =
                                    []; // This clears the suggestions list
                                _searchController.text =
                                    location; // Set the venue name
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setMapLocation(LatLng location, String name) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
    setState(() {
      _selectedLocation = location;
      _localVenueName = location;
      _searchController.text = name;
    });
  }

  // Future<LatLng> _getLatLngFromName(String name) async {
  //   // Implement a method to get LatLng from the location name
  //   // This could use another Google Maps API to get the LatLng of a location by its name
  //   return LatLng(1.3521, 103.8198);  // Dummy value, replace with the actual LatLng
  // }

  Future<LatLng> _getLatLngFromName(String name) async {
    final apiKey =
        'AIzaSyBMfLAQ0VJVMikgS7RsJz5pGmDVd6Dt6lE'; // Replace with your actual API key
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$name&key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body['results'] != null && body['results'].length > 0) {
        final location = body['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        return LatLng(lat, lng);
      } else {
        throw Exception('No results found for this location name.');
      }
    } else {
      throw Exception('Failed to fetch location coordinates.');
    }
  }

  Future<void> _getSuggestions(String input) async {
    final completer = Completer<List<String>>();
    final results = <String>[];

    js.context['dartGetSuggestionsCallback'] = (suggestionResults) {
      for (int i = 0; i < suggestionResults.length; i++) {
        results.add(suggestionResults[i].toString());
      }
      completer.complete(results);
    };

    js.context.callMethod('getPlaceSuggestions', [input]);
    final fetchedSuggestions = await completer.future;
    setState(() {
      suggestions = fetchedSuggestions;
    });
  }
}


// import 'dart:ui' as ui;
// import 'dart:js' as js;
// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class VenueBox extends StatefulWidget {
//   final String? id;

//   VenueBox({this.id});

//   @override
//   _VenueBoxState createState() => _VenueBoxState();
// }

// class _VenueBoxState extends State<VenueBox> {
//   bool locationPicked = false;
//   String? venueName;

//   void _showVenueInputDialog(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VenueDetailsPage(
//           venueName: venueName,
//           id: widget.id,
//           selectedLocation: locationPicked ? LatLng(1.3521, 103.8198) : null,
//           onVenueSelected: (String? name, LatLng? location) {
//             if (name != null && location != null) {
//               setState(() {
//                 venueName = name;
//                 locationPicked = true;
//               });
//             }
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _showVenueInputDialog(context);
//       },
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Color(0xff6858FE),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.location_on, color: Colors.white),
//             SizedBox(width: 10),
//             Text(
//               venueName ?? 'Select Tournament Venue',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             Spacer(),
//             Icon(Icons.arrow_forward_ios, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class VenueDetailsPage extends StatefulWidget {
//   final String? venueName;
//   final String? id;
//   final LatLng? selectedLocation;
//   final Function(String? name, LatLng? location) onVenueSelected;

//   VenueDetailsPage(
//       {required this.venueName,
//       required this.selectedLocation,
//       required this.onVenueSelected,
//       required this.id});

//   @override
//   VenueDetailsPageState createState() => VenueDetailsPageState();
// }

// class VenueDetailsPageState extends State<VenueDetailsPage> {
//   List<String> suggestions = [];
//   GoogleMapController? _mapController;
//   LatLng? _localVenueName;
//   LatLng? _selectedLocation;
//   TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _localVenueName = widget.selectedLocation;
//     _selectedLocation = widget.selectedLocation;
//     _searchController.text = widget.venueName ?? '';
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Icon(Icons.arrow_back_sharp)),
//                 SizedBox(width: 40),
//                 Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Text('Club',
//                       style: TextStyle(
//                           fontSize: 34,
//                           color: Color(0xff6858FE),
//                           fontFamily: 'karla',
//                           fontWeight: FontWeight.bold)),
//                   SizedBox(width: 5),
//                   Text('Match',
//                       style: TextStyle(
//                           fontSize: 34,
//                           color: Color(0xffFFA626),
//                           fontFamily: 'karla',
//                           fontWeight: FontWeight.bold)),
//                 ]),
//                 SizedBox(width: 30),
//                 Expanded(
//                   flex: 3,
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search for a location...',
//                       filled: true,
//                       fillColor: Color(0xffEEEEEE),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 15,
//                       ),
//                     ),
//                     onChanged: (value) => _getSuggestions(value),
//                   ),
//                 ),
//                 SizedBox(width: 30),
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     height: 40,
//                     decoration:
//                         BoxDecoration(borderRadius: BorderRadius.circular(15)),
//                     child: ElevatedButton(
//                       style: ButtonStyle(
//                           shape: MaterialStateProperty.all(
//                               RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15))),
//                           backgroundColor: MaterialStateProperty.all(
//                               Colors.deepPurpleAccent)),
//                       onPressed: () {
//                         widget.onVenueSelected(
//                             _localVenueName.toString(), _selectedLocation);
//                         FirebaseFirestore.instance
//                             .collection('events')
//                             .doc(widget.id)
//                             .set({
//                           'venue': _localVenueName,
//                           'lat': _selectedLocation?.latitude,
//                           'lng': _selectedLocation?.longitude,
//                         });
//                         Navigator.pop(
//                           context,
//                         );
//                       },
//                       child: Text('Submit'),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Expanded(
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: _selectedLocation ?? LatLng(1.3521, 103.8198),
//                     zoom: 15,
//                   ),
//                   onMapCreated: (controller) => _mapController = controller,
//                   markers: {
//                     if (_selectedLocation != null)
//                       Marker(
//                           markerId: MarkerId('selectedLocation'),
//                           position: _selectedLocation!,
//                           infoWindow:
//                               InfoWindow(title: _localVenueName.toString())),
//                   },
//                 ),
//                 if (suggestions.isNotEmpty)
//                   Positioned(
//                     top: 10,
//                     left: 20,
//                     right: 20,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       height: 200,
//                       child: ListView.builder(
//                         itemCount: suggestions.length,
//                         itemBuilder: (context, index) {
//                           final location = suggestions[index];
//                           return ListTile(
//                             title: Text(location),
//                             onTap: () => _searchController.text = location,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _getSuggestions(String input) async {
//     final completer = Completer<List<String>>();
//     final results = <String>[];

//     js.context['dartGetSuggestionsCallback'] = (suggestionResults) {
//       for (int i = 0; i < suggestionResults.length; i++) {
//         results.add(suggestionResults[i].toString());
//       }
//       completer.complete(results);
//     };

//     js.context.callMethod('getPlaceSuggestions', [input]);
//     final fetchedSuggestions = await completer.future;
//     setState(() {
//       suggestions = fetchedSuggestions;
//     });
//   }
// }







// this is the http request code ....

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class VenueBox extends StatefulWidget {
//   final String? id;

//   VenueBox({this.id});

//   @override
//   _VenueBoxState createState() => _VenueBoxState();
// }

// class _VenueBoxState extends State<VenueBox> {
//   bool locationPicked = false;
//   String? venueName;

//   void _showVenueInputDialog(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VenueDetailsPage(
//           venueName: venueName,
//           id: widget.id,
//           selectedLocation: locationPicked ? LatLng(1.3521, 103.8198) : null,
//           onVenueSelected: (String? name, LatLng? location) {
//             if (name != null && location != null) {
//               setState(() {
//                 venueName = name;
//                 locationPicked = true;
//               });
//             }
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _showVenueInputDialog(context);
//       },
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Color(0xff6858FE),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.location_on, color: Colors.white),
//             SizedBox(width: 10),
//             Text(
//               venueName ?? 'Select Tournament Venue',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             Spacer(),
//             Icon(Icons.arrow_forward_ios, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class VenueDetailsPage extends StatefulWidget {
//   final String? venueName;
//   final String? id;
//   final LatLng? selectedLocation;
//   final Function(String? name, LatLng? location) onVenueSelected;

//   VenueDetailsPage(
//       {required this.venueName,
//       required this.selectedLocation,
//       required this.onVenueSelected,
//       required this.id});

//   @override
//   VenueDetailsPageState createState() => VenueDetailsPageState();
// }

// class VenueDetailsPageState extends State<VenueDetailsPage> {
//   List<dynamic> suggestions = [];
//   GoogleMapController? _mapController;
//   LocationData? _currentLocation;
//   String? _localVenueName;
//   LatLng? _selectedLocation;

//   TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _localVenueName = widget.venueName;
//     _selectedLocation = widget.selectedLocation;
//     _searchController.text = _localVenueName ?? '';
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: Icon(Icons.arrow_back_sharp)),
//                 SizedBox(
//                   width: 40,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Club',
//                       style: TextStyle(
//                           fontSize: 34,
//                           color: Color(0xff6858FE),
//                           fontFamily: 'karla',
//                           fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       'Match',
//                       style: TextStyle(
//                           fontSize: 34,
//                           color: Color(0xffFFA626),
//                           fontFamily: 'karla',
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search for a location...',
//                       filled: true,
//                       fillColor: Color(0xffEEEEEE),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 15,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       _getSuggestions(value);
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     height: 40,
//                     decoration:
//                         BoxDecoration(borderRadius: BorderRadius.circular(15)),
//                     child: ElevatedButton(
//                       style: ButtonStyle(
//                           shape: MaterialStatePropertyAll(
//                               RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15))),
//                           backgroundColor: MaterialStatePropertyAll(
//                               Colors.deepPurpleAccent)),
//                       onPressed: () {
//                         widget.onVenueSelected(
//                             _localVenueName, _selectedLocation);
//                         FirebaseFirestore.instance
//                             .collection('events')
//                             .doc(widget.id)
//                             .set({
//                           'venue': _localVenueName,
//                           'lat': _selectedLocation?.latitude,
//                           'lng': _selectedLocation?.longitude
//                         });

//                         Navigator.pop(
//                           context,
//                         );
//                       },
//                       child: Text('Submit'),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: _selectedLocation ?? LatLng(1.3521, 103.8198),
//                     zoom: 15,
//                   ),
//                   onMapCreated: (controller) {
//                     _mapController = controller;
//                     _moveToSelectedLocation();
//                   },
//                   markers: {
//                     if (_currentLocation != null)
//                       Marker(
//                         markerId: MarkerId('currentLocation'),
//                         position: LatLng(
//                           _currentLocation!.latitude!,
//                           _currentLocation!.longitude!,
//                         ),
//                         infoWindow: InfoWindow(title: 'Current Location'),
//                       ),
//                     if (_selectedLocation != null)
//                       Marker(
//                         markerId: MarkerId('selectedLocation'),
//                         position: _selectedLocation!,
//                         infoWindow: InfoWindow(title: _localVenueName!),
//                       ),
//                   },
//                 ),
//                 if (suggestions.isNotEmpty)
//                   Positioned(
//                     top: 10,
//                     left: 20,
//                     right: 20,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       height: 200,
//                       child: _buildSuggestionsList(),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _getCurrentLocation() async {
//     Location location = Location();
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;
//     LocationData locationData;

//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         return;
//       }
//     }

//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     locationData = await location.getLocation();
//     setState(() {
//       _currentLocation = locationData;
//     });

//     if (_mapController != null) {
//       _mapController!.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: LatLng(locationData.latitude!, locationData.longitude!),
//             zoom: 15,
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> _getSuggestions(String input) async {
//     String KPLACES_API_KEY = 'AIzaSyBMfLAQ0VJVMikgS7RsJz5pGmDVd6Dt6lE';
//     String baseURL =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//     String request = '$baseURL?input=$input&key=$KPLACES_API_KEY';

//     var response = await http.get(Uri.parse(request));
//     if (response.statusCode == 200) {
//       setState(() {
//         suggestions =
//             json.decode(response.body)['predictions'] as List<dynamic>;
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   Widget _buildSuggestionsList() {
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final location = suggestions[index]['description'];
//         return ListTile(
//           onTap: () async {
//             _searchController.text = location;
//             String placeId = suggestions[index]['place_id'];
//             LatLng? selectedLocation = await _getSelectedLocation(placeId);
//             if (selectedLocation != null) {
//               setState(() {
//                 _localVenueName = location;
//                 _selectedLocation = selectedLocation;
//                 _moveToSelectedLocation();
//                 suggestions.clear();
//               });
//             }
//           },
//           title: Text(location),
//         );
//       },
//     );
//   }

//   Future<LatLng?> _getSelectedLocation(String placeId) async {
//     String KPLACES_API_KEY = 'AIzaSyBMfLAQ0VJVMikgS7RsJz5pGmDVd6Dt6lE';
//     String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
//     String request =
//         '$baseURL?place_id=$placeId&fields=geometry&key=$KPLACES_API_KEY';

//     var response = await http.get(Uri.parse(request));
//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);
//       if (data['status'] == 'OK') {
//         var lat = data['result']['geometry']['location']['lat'];
//         var lng = data['result']['geometry']['location']['lng'];
//         return LatLng(lat, lng);
//       }
//     }
//     return null;
//   }

//   void _moveToSelectedLocation() {
//     if (_mapController != null && _selectedLocation != null) {
//       _mapController!.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: _selectedLocation!,
//             zoom: 15,
//           ),
//         ),
//       );
//     }
//   }
// }
