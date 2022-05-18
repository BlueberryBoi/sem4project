// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:chat_app/data.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  User? currentUser;
  String? username;
  String imageString = '';

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<Data>(context, listen: true).currentUser;
    username = currentUser!.username;
    imageString = currentUser!.profileImage;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height / 1.24,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 35.0,
                ),
                Flexible(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: CircleAvatar(
                          // ignore: unnecessary_null_comparison
                          backgroundImage: currentUser!.isProfileImageSet
                              ? MemoryImage(base64Decode(imageString))
                              : AssetImage(imageString) as ImageProvider,
                          radius: 60.0,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 12.0,
                            ),
                            Flexible(
                              child: Text(
                                currentUser!.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
                            Flexible(
                              child: Text(
                                "@$username",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height * 2 / 4.8,
                          ),
                          child: Column(
                            children: [
                              ProfileTile(
                                icon: Icons.email,
                                number: null,
                                text: currentUser!.email,
                              ),
                              ProfileTile(
                                icon: FontAwesomeIcons.peopleGroup,
                                number: currentUser!.contacts.length,
                                text: "    Friends",
                              ),
                              ProfileTile(
                                icon: FontAwesomeIcons.solidMessage,
                                number: Provider.of<Data>(context, listen: true)
                                    .getChatList
                                    .length,
                                text: "    Chats",
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<Data>(context, listen: false)
                              .deleteUserCredentials();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              'SplashScreen', (Route<dynamic> route) => false);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.red.shade100,
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.red,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    Key? key,
    required this.icon,
    required this.text,
    required this.number,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final int? number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 8.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: 30.0,
              color: Colors.grey.shade800, // color: Colors.grey.shade600,
            ),
            Row(
              children: [
                if (number != null)
                  Text(
                    number.toString(),
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0,
                    ),
                  ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
