import 'package:chat_app/Screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/Screens/login_screen.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future alreadyLoggedIn(String username, String password) async {
      final dynamic response;
      final User user;
      try {
        response = await http.post(
          Uri.parse('$url/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': username.toLowerCase(),
            'password': password,
          }),
        );
      } catch (e) {
        throw Exception('Error connecting to the database');
      }

      user = User.fromJson(jsonDecode(response.body));
      // ignore: unnecessary_null_comparison
      if (user.name != null) {
        print(response.body);
        Provider.of<Data>(context, listen: false).setCurrentUser(user);
        return;
      } else {
        dynamic decodedData = jsonDecode(response.body);
        throw Exception(decodedData["error"]);
      }
    }

    bool? where;
    _() async {
      prefs = await SharedPreferences.getInstance();
      where = await Provider.of<Data>(context, listen: false).isLoggedIn();
      if (where == true) {
        String? username =
            await Provider.of<Data>(context, listen: false).getUsername();
        String? password =
            await Provider.of<Data>(context, listen: false).getPassword();
        await alreadyLoggedIn(username!, password!);
      }
    }

    return FutureBuilder(
      future: _(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (where == true) {
            return const MainScreen();
          } else {
            return const LogInScreen();
          }
        } else {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: SizedBox(
              height: 200,
              width: 200,
              child: Image(
                image: AssetImage('images/chat_app_logo.png'),
              ),
            )),
          );
        }
      },
    );
  }
}
