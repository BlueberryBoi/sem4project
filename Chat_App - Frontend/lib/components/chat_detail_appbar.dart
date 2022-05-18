import 'dart:convert';
import 'package:chat_app/models/chat_model.dart';
import 'package:flutter/material.dart';

class ChatDetailPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  // ignore: use_key_in_widget_constructors
  const ChatDetailPageAppBar(this.chat);
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              CircleAvatar(
                backgroundImage: chat.isProfileImageSet
                    ? MemoryImage(base64Decode(chat.image))
                    : AssetImage(chat.image) as ImageProvider,
                maxRadius: 26,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      chat.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "Online",
                      style: TextStyle(color: Colors.green, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade700,
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(80.0);
}
