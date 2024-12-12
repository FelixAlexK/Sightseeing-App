import 'package:flutter/material.dart';
import '../models/place.dart';

class PlaceDetailPage extends StatelessWidget {
  final Place place;

  PlaceDetailPage({required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/' + place.imageUrl,
              height: 200, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  place.description,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16.0),
                // Date
                Text(
                  "Date: ${place.date}",
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                ),
                SizedBox(height: 8.0),
                // Coordinates
                Text(
                  "Coordinates: ${place.cord}",
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
