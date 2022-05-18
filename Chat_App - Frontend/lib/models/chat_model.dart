class Chat {
  Chat({
    required this.name,
    required this.username,
    required this.latestMessage,
    required this.image,
    required this.time,
    required this.isRead,
    required this.isProfileImageSet,
  });

  final String name;
  final String username;
  final String latestMessage;
  final String image;
  final String time;
  final bool isRead;
  final bool isProfileImageSet;

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      name: json["name"],
      username: json["username"],
      latestMessage: json["latest_msg"]["content"],
      time: json["latest_msg"]["time"],
      isRead: false,
      isProfileImageSet: json['isProfileImageSet'],
      image: json["isProfileImageSet"] == true
          ? json["profileImage"]
          : 'images/default.png',
    );
  }
}
