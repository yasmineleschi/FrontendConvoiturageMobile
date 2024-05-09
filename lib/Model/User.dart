class User {
  String? id;
  String? username;
  String? email;
  String? password;
  String? age;
  String? photoProfile;
  String? phone;
  String? firstname;
  String? lastname;
  String? address;
  String? etat;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.age,
    required this.photoProfile,
    required this.phone,
    required this.firstname,
    required this.lastname,
    required this.address,
    required this.etat,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      age: json['age'],
      photoProfile: json['photoProfile'],
      phone: json['phone'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      address: json['address'],
      etat: json['etat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'password': password,
      'age': age,
      'photoProfile': photoProfile,
      'phone': phone,
      'firstname': firstname,
      'lastname': lastname,
      'address': address,
      'etat': etat,
    };
  }
}
