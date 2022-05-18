import 'package:flutter/material.dart';
import 'models/chat_message.dart';
import 'models/chat_model.dart';
import 'models/user.dart';

enum MessageType {
  sender,
  receiver,
}

late final prefs;

class Data extends ChangeNotifier {
  final List<Chat> _chatList = [];
  final List<ChatMessage> _chatMessages = [];
  late User _currentUser;
  bool? _isLoggedIn;

  Future<bool?> isLoggedIn() async {
    bool? result;
    try {
      result = prefs.getBool('loggedIn');
    } catch (e) {
      result = null;
    }
    if (result == null) {
      _isLoggedIn = false;
      return false;
    } else {
      _isLoggedIn = true;
      return result;
    }
  }

  Future setLoggedInStatus(bool value) async {
    _isLoggedIn = await prefs.setBool('loggedIn', value);

    notifyListeners();
  }

  void storeUserCredentials(String username, String password) async {
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  void deleteUserCredentials() async {
    setLoggedInStatus(false);
    await prefs.remove('loggedIn');
    await prefs.remove('username');
    await prefs.remove('password');
  }

  Future<String?> getUsername() async {
    return prefs.getString('username');
  }

  Future<String?> getPassword() async {
    return prefs.getString('password');
  }

  User get currentUser {
    return _currentUser;
  }

  List<Chat> get getChatList {
    return _chatList;
  }

  List<ChatMessage> get getChatMessages {
    return _chatMessages;
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void addChatMessage(ChatMessage chatMessage) {
    _chatMessages.add(chatMessage);
    notifyListeners();
  }

  void setChatList(List<Chat> chats) {
    _chatList.clear();
    _chatList.addAll(chats);
    notifyListeners();
  }

  void setChatMessages(List<ChatMessage> chatMessages) {
    _chatMessages.clear();
    _chatMessages.addAll(chatMessages);
    notifyListeners();
  }
}
