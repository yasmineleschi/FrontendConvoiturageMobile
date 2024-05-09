import 'package:flutter/foundation.dart';

class Reservation {
  final String? id;
  final String userId;
  final String carId;
  final DateTime reservationDateTime;
  final int numberOfPassengers;
  final double totalPrice;
  final String paymentMethod;
  final String contactInfo;
  final String status;

  Reservation({
    required this.id,
    required this.userId,
    required this.carId,
    required this.reservationDateTime,
    required this.numberOfPassengers,
    required this.totalPrice,
    required this.paymentMethod,
    required this.contactInfo,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['_id'],
      userId: json['user'],
      carId: json['car'],
      reservationDateTime: DateTime.parse(json['reservationDateTime']),
      numberOfPassengers: json['numberOfPassengers'],
      totalPrice: json['totalPrice'].toDouble(),
      paymentMethod: json['paymentMethod'],
      contactInfo: json['contactInfo'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'car': carId,
      'reservationDateTime': reservationDateTime.toIso8601String(),
      'numberOfPassengers': numberOfPassengers,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'contactInfo': contactInfo,
      'status': status,
    };
  }
}
