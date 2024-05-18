class User {
  final String userId;
  final String username;
  final String? age;
  final String? lastname;
  final String? phone;
  final String? address;
  final String? image;

  User({
    required this.userId,
    required this.username,
    this.age,
    this.lastname,
    this.phone,
    this.address,
    this.image,
  });
}
