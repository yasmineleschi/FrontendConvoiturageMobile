// lib/models/reservation.dart
class Reservation {
  final String id;
  final String? contactInfo;
  final double? totalPrice;
  final int? numberOfPassengers;
  final String? reservationDateTime;
  final String? paymentMethod;
  final String? status;

  Reservation({
    required this.id,
    required this.contactInfo,
    required this.totalPrice,
    required this.numberOfPassengers,
    required this.reservationDateTime,
    required this.paymentMethod,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['_id'],
      contactInfo: json['contactInfo'],
      totalPrice: json['totalPrice']?.toDouble(),
      numberOfPassengers: json['numberOfPassengers'],
      reservationDateTime: json['reservationDateTime'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
    );
  }
}
