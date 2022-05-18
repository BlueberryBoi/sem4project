// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_app/Screens/search_screen.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/data.dart';
import 'package:provider/provider.dart';
import '../components/chat_tile.dart';
import '../components/search_bar.dart';
import '../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future future;
  List<Chat> chatList = [];
  int times = 0;
  bool showSpinner = false;

  Future fetchContacts() async {
    setState(() {
      showSpinner = true;
    });
    // //
    List<Chat> _chatList = [];
    int length = 0;
    final currentUser =
        Provider.of<Data>(context, listen: false).currentUser.username;

    final response = await http.get(Uri.parse('$url/contacts/$currentUser'));
    length = jsonDecode(response.body).length;

    for (int i = 0; i < length; i++) {
      Chat chat = Chat.fromJson(jsonDecode(response.body)[i]);
      if (chat.name != null) {
        _chatList.add(chat);
      }
    }

    print(response.body);
    Provider.of<Data>(context, listen: false).setChatList(_chatList);

    setState(() {
      showSpinner = false;
    });

    return;
  }

  @override
  void initState() {
    super.initState();
    future = fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    chatList = Provider.of<Data>(context, listen: true).getChatList;

    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //   // Row(
              //   //   mainAxisAlignment: MainAxisAlignment.start,
              //   //   children: const [
              const Text(
                'Chats',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // //   ],
              // // ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Hero(
                  tag: "search bar",
                  child: Material(
                    child: SearchBar(
                      autoFocus: false,
                      showIcon: false,
                      icon: null,
                      onChanged: (value) {},
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return SearchScreen();
                          },
                        )).then((value) => fetchContacts());
                      },
                      onIconPressed: () {},
                    ),
                  ),
                ),
              ),
              FutureBuilder(
                future: future,
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      if (showSpinner == true)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Colors.pink,
                          ),
                        ),
                      ListView.builder(
                        itemCount: chatList.length,
                        shrinkWrap: true,
                        // physics: const BouncingScrollPhysics(
                        //   parent: AlwaysScrollableScrollPhysics(),
                        // ),
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: ((context, index) {
                          return ChatTile(
                            name: chatList[index].name,
                            username: chatList[index].username,
                            secondaryText: chatList[index].latestMessage,
                            image: chatList[index].image,
                            time: chatList[index].time,
                            isRead: chatList[index].isRead,
                            isProfileImageSet:
                                chatList[index].isProfileImageSet,
                            afterPop: () {
                              fetchContacts();
                            },
                          );
                        }),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
