import 'dart:convert';
import 'package:chat_app/components/search_bar.dart';
import 'package:chat_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? contact_username;

  Widget? icon = null;

  @override
  Widget build(BuildContext context) {
    // Future searchUsername(String searchString) async {
    //   final response;
    //   try {
    //     response = await http.get(Uri.parse('$url/$searchString'));
    //     dynamic decodedData = await jsonDecode(response.body);
    //     print(decodedData);
    //   } catch (e) {
    //     print(e);
    //   }
    //   return;
    // }
    Future addContact() async {
      setState(() {
        icon = const SizedBox(
          height: 20.0,
          width: 20.0,
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        );
      });

      final dynamic response;
      final currentUser = Provider.of<Data>(context, listen: false).currentUser;

      try {
        response = await http.post(
          Uri.parse('$url/addContact'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': currentUser.username,
            'contact_username': contact_username!.trim(),
          }),
        );
      } catch (e) {
        throw Exception('Error connecting to the database');
      }

      final dynamic decodedData = jsonDecode(response.body);
      print(response.body);

      setState(() {
        if (decodedData['msg'] != null) {
          icon = const Icon(
            Icons.check,
            color: Colors.green,
          );
        } else {
          icon = const Icon(
            Icons.close,
            color: Colors.red,
          );
        }
      });
    }

    // Future searchUsername() async {}

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 8.0, top: 20.0, bottom: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.arrowLeft),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Hero(
                      tag: "search bar",
                      child: Material(
                        child: SearchBar(
                          icon: icon,
                          autoFocus: true,
                          showIcon: true,
                          onIconPressed: () {
                            // searchUsername(contact_username!);
                            if (contact_username != null) {
                              int times = 0;
                              if (times == 0) {
                                addContact();
                                times++;
                              }
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              icon = null;
                            });
                            if (value == '') {
                              contact_username = null;
                            } else {
                              contact_username = value;
                            }
                          },
                          onTap: () {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
