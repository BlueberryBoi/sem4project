import 'package:chat_app/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data.dart';

// ignore_for_file: must_be_immutable
class ChatBubble extends StatefulWidget {
  ChatMessage chatMessage;

  // ignore: use_key_in_widget_constructors
  ChatBubble({required this.chatMessage});

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Align(
        alignment: (widget.chatMessage.type == MessageType.receiver
            ? Alignment.topLeft
            : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: (widget.chatMessage.type == MessageType.receiver
                ? Colors.pink.shade100
                : Colors.grey.shade400),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(widget.chatMessage.message),
        ),
      ),
    );
  }
}
