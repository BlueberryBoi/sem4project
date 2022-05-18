import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileImageUploaderSheet extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ProfileImageUploaderSheet({
    required this.galleryOnTap,
    required this.cameraOnTap,
  });

  final Function() galleryOnTap;
  final Function() cameraOnTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff737373),
      child: Container(
        height: 220.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 40.0, top: 10.0, left: 10.0, right: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Upload Profile Picture',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: galleryOnTap,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            FontAwesomeIcons.image,
                            color: Colors.pink,
                            size: 30.0,
                          ),
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: cameraOnTap,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            FontAwesomeIcons.camera,
                            color: Colors.pink,
                            size: 30.0,
                          ),
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
