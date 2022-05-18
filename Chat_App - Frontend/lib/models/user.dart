class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.isProfileImageSet,
    required this.profileImage,
    required this.contacts,
  });

  final String id;
  final String name;
  final String username;
  final String email;
  final bool isProfileImageSet;
  final String profileImage;
  final List contacts;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      name: json['name'],
      username: json["username"],
      email: json["email"],
      isProfileImageSet: json["isProfileImageSet"],
      profileImage: json["isProfileImageSet"] == true
          ? json["profileImage"]
          : 'images/default.png',
      contacts: json["contacts"],
    );
  }
}
