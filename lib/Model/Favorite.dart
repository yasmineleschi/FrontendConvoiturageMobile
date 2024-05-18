class Favorite {
  final String? id;
  final Map<String, dynamic> car;
  final Map<String, dynamic> user;
  final DateTime dateCreation;

  Favorite({
    required this.id,
    required this.car,
    required this.user,
    required this.dateCreation,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['_id'],
      car: json['car'],
      user: json['user'],
      dateCreation: DateTime.parse(json['datecreation']),
    );
  }
}
