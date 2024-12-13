import 'package:flutter/material.dart';
import '../models/place.dart';
import 'place_detail_page.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  final List<Place> places;

  const HistoryPage({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
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
          // Foreground ListView
          ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(place.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('EEEE, MMMM d, yyyy')
                          .format(place.date)), // Display date
                      Text(place.cord), // Display coordinates
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailPage(place: place),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
