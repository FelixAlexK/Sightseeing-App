import 'package:flutter/material.dart';
import '../models/place.dart';
import 'place_detail_page.dart';

class HistoryPage extends StatelessWidget {
  final List<Place> places;

  HistoryPage({required this.places});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: ListView.builder(
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
                  Text(place.date), // Display date
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
    );
  }
}
