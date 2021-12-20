class Location {
  Location({
    required this.longtidue,
    required this.latidute,
    required this.detail,
    required this.name,
    required this.image,
  });

  double longtidue;
  double latidute;
  String detail;
  String name;
  String image;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        longtidue: json["longtidue"].toDouble(),
        latidute: json["latidute"].toDouble(),
        detail: json["detail"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "longtidue": longtidue,
        "latidute": latidute,
        "detail": detail,
        "name": name,
        "image": image,
      };
}
