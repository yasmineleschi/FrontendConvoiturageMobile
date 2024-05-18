class Offer {
  final String id;
  final String departureLocation;
  final String destinationLocation;
  final String departureDateTime;
  final int seatAvailable;
  final int seatPrice;
  final String userId;
  final int numberOfPassengers;

  Offer({
    required this.id,
    required this.departureLocation,
    required this.destinationLocation,
    required this.departureDateTime,
    required this.seatAvailable,
    required this.seatPrice,
    required this.userId,
    required this.numberOfPassengers,
  });
}
