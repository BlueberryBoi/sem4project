import 'dart:convert';
import 'package:chat_app/Screens/chat_details.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const ChatTile({
    required this.name,
    required this.username,
    required this.secondaryText,
    required this.image,
    required this.time,
    required this.isRead,
    required this.isProfileImageSet,
    required this.afterPop,
  });

  final String name;
  final String username;
  final String secondaryText;
  final String image;
  final String time;
  final bool isRead;
  final bool isProfileImageSet;
  final Function() afterPop;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  late Chat chat;

  @override
  Widget build(BuildContext context) {
    chat = Chat(
      name: widget.name,
      username: widget.username,
      latestMessage: widget.secondaryText,
      image: widget.image,
      time: widget.time,
      isRead: widget.isRead,
      isProfileImageSet: widget.isProfileImageSet,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatDetail(chat)),
        ).then((value) {
          widget.afterPop();
        });
      },
      child: Container(
        padding: const EdgeInsets.only(left: 2.0, right: 2.0, top: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.isProfileImageSet
                        ? MemoryImage(base64Decode(widget.image))
                        : AssetImage(widget.image) as ImageProvider,
                    maxRadius: 30.0,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          widget.secondaryText,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: widget.isRead ? Colors.grey.shade500 : Colors.pink,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Container(
              color: Colors.grey.shade800,
              height: 0.2,
            ),
          ],
        ),
      ),
    );
  }
}
