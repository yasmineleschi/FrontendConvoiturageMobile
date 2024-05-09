class Offer {
  String? id;
  String? image;
  DateTime? departureDateTime;
  String? departureLocation;
  String? destinationLocation;
  double? seatPrice;
  String? seatAvailable;
  String? model;
  String? matricule;
  String? status;
  String? userId;

  Offer({
   this.id,
    this.image,
    this.departureDateTime,
    this.departureLocation,
    this.destinationLocation,
    this.seatPrice,
    this.seatAvailable,
    this.model,
    this.matricule,
    this.status,
    this.userId,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'],
      image: json['image'],
      departureDateTime: json['departureDateTime'] != null
          ? DateTime.parse(json['departureDateTime'])
          : null,
      departureLocation: json['departureLocation'],
      destinationLocation: json['destinationLocation'],
      seatPrice: json['seatPrice'] != null ? json['seatPrice'].toDouble() : null,
      seatAvailable: json['seatAvailable'],
      model: json['model'],
      matricule: json['matricule'],
      status: json['status'],
      userId: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'departureDateTime':
      departureDateTime != null ? departureDateTime!.toIso8601String() : null,
      'departureLocation': departureLocation,
      'destinationLocation': destinationLocation,
      'seatPrice': seatPrice,
      'seatAvailable': seatAvailable,
      'model': model,
      'matricule': matricule,
      'status': status,
      'user': userId,
    };
  }
}
