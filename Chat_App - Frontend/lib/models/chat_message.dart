import 'package:chat_app/data.dart';

class ChatMessage {
  ChatMessage({required this.message, required this.type});

  String message;
  MessageType type;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['content'],
      type: json['from'],
    );
  }
}
