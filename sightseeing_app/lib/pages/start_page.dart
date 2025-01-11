import 'package:flutter/material.dart';
import 'package:sightseeing_app/pages/options_page.dart';
import 'package:sightseeing_app/pages/history_page.dart';
import 'package:sightseeing_app/models/place.dart';
import 'package:sightseeing_app/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  _StartPageState createState() => _StartPageState();


}
  
class _StartPageState extends State<StartPage> {

  @override
  void initState() {
    super.initState();
    _loadPlacesBeen();
  }

  Future<bool> _hasStoredPlace() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('selectedPlace');
  }

  Future<void> _loadPlacesBeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? placesJson = prefs.getStringList('placesBeen');
    if (placesJson != null) {
      setState(() {
        placesBeen = placesJson.map((placeJson) => Place.fromJson(jsonDecode(placeJson))).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/map.jpg'), context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/map.jpg'),
                fit: BoxFit.cover,
                opacity: 1.0,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.darken))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SightVenture',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.blue,
                          offset: Offset(5, 5),
                        ),
                      ]),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OptionsPage()))
                                  },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                elevation: 8,
                                padding: EdgeInsetsDirectional.symmetric(
                                    vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                'Start',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                              )))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: FutureBuilder<bool>(
                            future: _hasStoredPlace(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final hasStoredPlace = snapshot.data ?? false;
                                return ElevatedButton(
                                  onPressed: hasStoredPlace
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MainPage(useStoredPlace: true, maxDistance: -1),
                                          ),
                                        );
                                      }
                                    : null,
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                      strokeAlign: BorderSide.strokeAlignInside,
                                    ),
                                    elevation: 8,
                                    padding: EdgeInsetsDirectional.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    disabledBackgroundColor: Colors.grey,
                                  ),
                                  child: Text(
                                    'Resume',
                                    style: TextStyle(color: Colors.blue, fontSize: 24),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HistoryPage(
                                                  places: placesBeen,
                                                )))
                                  },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignInside),
                                elevation: 8,
                                padding: EdgeInsetsDirectional.symmetric(
                                    vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                'History',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 24),
                              )))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
