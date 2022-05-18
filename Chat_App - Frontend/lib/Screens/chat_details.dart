import 'dart:convert';
import 'package:chat_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/chat_bubble.dart';
import '../components/chat_detail_appbar.dart';
import '../data.dart';
import '../models/chat_message.dart';
import '../models/chat_model.dart';
import '../models/send_menu_items.dart';
import 'package:http/http.dart' as http;

class ChatDetail extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const ChatDetail(this.chat);

  final Chat chat;

  @override
  _ChatDetailState createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  List<ChatMessage> chatMessages = [];
  String? message;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future fetchChats() async {
    final dynamic response;
    List<ChatMessage> _chatMessages = [];
    int length = 0;

    final currentUser = Provider.of<Data>(context, listen: false).currentUser;

    try {
      response = await http.post(
        Uri.parse('$url/chatmsgs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'from': currentUser.username,
          'to': widget.chat.username,
        }),
      );
    } catch (e) {
      throw Exception('Error connecting to the database');
    }

    print(response.body);

    final dynamic decodedData = jsonDecode(response.body);
    length = decodedData.length;

    for (int i = 0; i < length; i++) {
      MessageType type = decodedData[i]["from"] == currentUser.username
          ? MessageType.sender
          : MessageType.receiver;

      ChatMessage chatMessage =
          ChatMessage(message: decodedData[i]["content"], type: type);
      _chatMessages.add(chatMessage);
    }

    Provider.of<Data>(context, listen: false).setChatMessages(_chatMessages);

    if (decodedData != null && length > 10) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100.0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

  Future sendChat() async {
    final dynamic response;
    final currentUser = Provider.of<Data>(context, listen: false).currentUser;

    try {
      response = await http.post(
        Uri.parse('$url/msg'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'from': currentUser.username,
          'to': widget.chat.username,
          'content': message!,
        }),
      );
    } catch (e) {
      throw Exception('Error connecting to the database');
    }

    print(response.body);
    int times = 0;
    if (times == 0) {
      fetchChats();
      times++;
    }
  }

  List<SendMenuItems> menuItems = [
    SendMenuItems(
        text: "Photos & Videos", icons: Icons.image, color: Colors.amber),
    SendMenuItems(
        text: "Document", icons: Icons.insert_drive_file, color: Colors.blue),
    SendMenuItems(text: "Audio", icons: Icons.music_note, color: Colors.orange),
    SendMenuItems(
        text: "Location", icons: Icons.location_on, color: Colors.green),
    SendMenuItems(text: "Contact", icons: Icons.person, color: Colors.purple),
  ];

  void showModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              color: const Color(0xff737373),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Container(
                          height: 4,
                          width: 50,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        itemCount: menuItems.length,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: menuItems[index].color.shade50,
                                ),
                                height: 50,
                                width: 50,
                                child: Icon(
                                  menuItems[index].icons,
                                  size: 20,
                                  color: menuItems[index].color.shade400,
                                ),
                              ),
                              title: Text(menuItems[index].text),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (chatMessages.length > 10) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100.0,
          duration: const Duration(seconds: 1),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    // Provider.of<Data>(context, listen: false).setChatMessages([]);
    super.dispose();
  }

  int times = 0;
  @override
  Widget build(BuildContext context) {
    if (times == 0) {
      fetchChats();
      times++;
    }
    chatMessages = Provider.of<Data>(context, listen: true).getChatMessages;

    return Scaffold(
      appBar: ChatDetailPageAppBar(widget.chat),
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatMessages.length,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ChatBubble(
                  chatMessage: chatMessages[index],
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 16, bottom: 10),
              height: 80,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showModal();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 62.0),
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Type message...",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value == '') {
                                message = null;
                              } else {
                                message = value;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.only(right: 30, bottom: 50),
              child: FloatingActionButton(
                onPressed: () {
                  _controller.clear();
                  if (message != null) {
                    Provider.of<Data>(context, listen: false).addChatMessage(
                      ChatMessage(message: message!, type: MessageType.sender),
                    );
                    if (chatMessages.length > 10) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent + 100.0,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    }
                    sendChat();
                  }
                },
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                backgroundColor: Colors.pink,
                elevation: 1.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
