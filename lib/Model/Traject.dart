class CarRide {
  final String id;
  final String image;
  final DateTime departureDateTime;
  final String departureLocation;
  final String destinationLocation;
  final DateTime? destinationDateTime;
  final double seatPrice;
  final int seatAvailable;
  final String user;
  final DateTime createdAt;
  final DateTime updatedAt;

  CarRide({
    required this.id,
    required this.image,
    required this.departureDateTime,
    required this.departureLocation,
    required this.destinationLocation,
    this.destinationDateTime,
    required this.seatPrice,
    required this.seatAvailable,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarRide.fromJson(Map<String, dynamic> json) {
    return CarRide(
      id: json['_id'],
      image: json['image'],
      departureDateTime: DateTime.parse(json['departureDateTime']),
      departureLocation: json['departureLocation'],
      destinationLocation: json['destinationLocation'],
      destinationDateTime: json['destinationDateTime'] != null
          ? DateTime.parse(json['destinationDateTime'])
          : null, // Handle optional destinationDateTime
      seatPrice: (json['seatPrice'] as num).toDouble(),
      seatAvailable: json['seatAvailable'],
      user: json['user'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}