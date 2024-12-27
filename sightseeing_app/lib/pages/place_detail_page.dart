import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/place.dart';
import 'start_page.dart'; // Import your StartPage

class PlaceDetailPage extends StatelessWidget {
  final Place place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/map.jpg'), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/${place.imageUrl}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        place.description,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // White text for contrast
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color:
                                  Colors.black, // Shadow for better visibility
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      // Date
                      Text(
                        "Date: ${DateFormat('EEEE, MMMM d, yyyy').format(place.date)}",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      // Coordinates
                      Text(
                        "Coordinates: ${place.cord}",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      // Coordinates
                      Text(
                        "Difficylty: ${place.diff == 2 ? 'hard' : 'easy'}",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0), // Add spacing before the button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StartPage(), // Navigate to StartPage
                        ),
                        (route) => false, // Remove all previous routes
                      );
                    },
                    child: Text("Back to Start Page"),
                  ),
                ),
                SizedBox(height: 16.0), // Add spacing after the button
              ],
            ),
          ),
        ],
      ),
    );
  }
}
