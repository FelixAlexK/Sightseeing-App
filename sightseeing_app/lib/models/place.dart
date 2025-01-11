class Place {
  final String name;
  final String description;
  final String imageUrl;
  final String cord;
  final DateTime date;
  final int diff;

  Place({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cord,
    required this.date,
    required this.diff, //0 not done,1 easy, 2 hard
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'cord': cord,
    'date': date.toIso8601String(),
    'diff': diff,
  };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    name: json['name'],
    description: json['description'],
    imageUrl: json['imageUrl'],
    cord: json['cord'],
    date: DateTime.parse(json['date']),
    diff: json['diff'],
  );
}

int at = 1;
int currentDiff = 2;
List<Place> places = [
  Place(
      name: "Örebro University",
      description:
          "An university in the middle of Sweden. Here you can study Mobile Platforms",
      date: DateTime(2024, 12, 25),
      cord: "59.2543° N, 15.2484° E",
      imageUrl: "nophoto.jpg",
      diff: 0),
  Place(
      name: "Örebro Casle",
      description: "An casle in the middle of Örebro. It was oppend in 1270",
      date: DateTime(2024, 12, 25),
      cord: "59.2741° N, 15.2154° E",
      imageUrl: "nophoto.jpg",
      diff: 0),
  Place(
      name: "Svampen",
      description:
          "Watertower in örebro. Its 58 meters high and conatinas 9 million liters",
      date: DateTime(2024, 12, 25),
      cord: "59.2880° N, 15.2254° E",
      imageUrl: "nophoto.jpg",
      diff: 0),
  Place(
      name: "Felix and Svens home",
      description: "Home of two magnificent men",
      date: DateTime(2024, 12, 25),
      cord: "59.2528° N, 15.2464° E",
      imageUrl: "nophoto.jpg",
      diff: 0)
];
List<Place> placesBeen = [];
