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
      this.imageUrl = "nophoto.jpg",
      required this.cord,
      required this.date,
      required this.beenHere});
}
