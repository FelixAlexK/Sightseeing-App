class Place {
  final String name;
  final String description;
  final String imageUrl;
  final String cord;
  final DateTime date;
  final bool beenHere;

  Place(
      {required this.name,
      required this.description,
      required this.imageUrl,
      required this.cord,
      required this.date,
      required this.beenHere});
}

int at = 1;
List<Place> places = [
  Place(
      name: "Eiffel Tower",
      description: "An iconic symbol of Paris, France.",
      date: DateTime(2024, 12, 25),
      cord: "48.8584° N, 2.2945° E",
      beenHere: false,
      imageUrl: "nophoto.jpg"),
  Place(
      name: "Great Wall of China",
      description: "A historic wall spanning across northern China.",
      date: DateTime(2024, 12, 25),
      cord: "40.4319° N, 116.5704° E",
      beenHere: false,
      imageUrl: "nophoto.jpg"),
  Place(
      name: "Taj Mahal",
      description: "A magnificent mausoleum in India.",
      date: DateTime(2024, 12, 25),
      cord: "27.1751° N, 78.0421° E",
      beenHere: false,
      imageUrl: "nophoto.jpg"),
];
List<Place> placesBeen = [
  Place(
      name: "Eiffel Tower",
      description: "An iconic symbol of Paris, France.",
      date: DateTime(2024, 12, 25),
      cord: "48.8584° N, 2.2945° E",
      beenHere: false,
      imageUrl: "nophoto.jpg"),
  Place(
      name: "Great Wall of China",
      description: "A historic wall spanning across northern China.",
      date: DateTime(2024, 12, 25),
      cord: "40.4319° N, 116.5704° E",
      beenHere: false,
      imageUrl: "nophoto.jpg"),
  Place(
      name: "Taj Mahal",
      description: "A magnificent mausoleum in India.",
      date: DateTime(2024, 12, 25),
      cord: "27.1751° N, 78.0421° E",
      beenHere: false,
      imageUrl: "nophoto.jpg"),
];
