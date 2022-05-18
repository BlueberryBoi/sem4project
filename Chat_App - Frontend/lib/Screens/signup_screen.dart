// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chat_app/data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:chat_app/constants.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/components/profile_image_uploader_sheet.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _imageFile;
  User? _user;

  String? name;
  String? username;
  String? email;
  String? password;
  bool _showSpinner = false;

  List<String> signUpFields = [
    'Enter your name',
    'Enter you username',
    'Enter your email',
    'Enter you password'
  ];

  List<TextInputType> signUpKeyboards = [
    TextInputType.name,
    TextInputType.name,
    TextInputType.emailAddress,
    TextInputType.visiblePassword,
  ];

  void takePhoto(ImageSource source) async {
    final _pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _imageFile = _pickedFile!.path;
    });
  }

  Future uploadProflieImage(String filename) async {
    var request = http.MultipartRequest('POST', Uri.parse("$url/uploadimage"));
    try {
      request.fields['username'] = username!;
      request.files.add(
        http.MultipartFile(
          'mypic',
          File(filename).readAsBytes().asStream(),
          File(filename).lengthSync(),
          filename: username!,
        ),
      );
    } catch (e) {
      rethrow;
    }
    await request.send();
  }

  Future<User> createUser(
    String name,
    String username,
    String email,
    String password,
  ) async {
    final http.Response response;
    final User user;
    try {
      response = await http.post(
        Uri.parse('$url/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'username': username,
          'email': email,
          'password': password,
        }),
      );
    } catch (e) {
      throw Exception("Error connecting to the database");
    }
    user = User.fromJson(jsonDecode(response.body));
    if (user.name != null) {
      print(response.body);
      Provider.of<Data>(context, listen: false).setCurrentUser(user);
      return user;
    } else {
      print(response.body);
      dynamic decodedData = jsonDecode(response.body);
      throw Exception(decodedData["error"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    List<Function(String)> signUpFunctions = [
      (value) {
        if (value == '') {
          name = null;
        } else {
          name = value;
        }
      },
      (value) {
        if (value == '') {
          username = null;
        } else {
          username = value;
        }
      },
      (value) {
        if (value == '') {
          email = null;
        } else {
          email = value;
        }
      },
      (value) {
        if (value == '') {
          password = null;
        } else {
          password = value;
        }
      },
    ];

    void signUp() {
      setState(() {
        _showSpinner = true;
      });
      Future.delayed(
        const Duration(seconds: 2),
        () async {
          try {
            _user = await createUser(
              name!,
              username!.toLowerCase(),
              email!.toLowerCase(),
              password!,
            );
            if (_imageFile != null) {
              await uploadProflieImage(_imageFile!);
            }

            if (_user!.name != null) {
              Provider.of<Data>(context, listen: true).setLoggedInStatus(true);
              Provider.of<Data>(context, listen: false)
                  .storeUserCredentials(username!, password!);
              Navigator.popAndPushNamed(context, 'main');
            }
          } catch (e) {
            print(e.toString());
            AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              animType: AnimType.SCALE,
              title: e.toString().substring(11),
              btnOkOnPress: () {},
            ).show();
          }

          setState(() {
            _showSpinner = false;
          });
        },
      );
    }

    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height / 1.2,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 80.0,
                              backgroundImage: _imageFile != null
                                  ? FileImage(File(_imageFile!))
                                      as ImageProvider
                                  : AssetImage('images/default.png'),
                            ),
                            Positioned(
                              bottom: 0,
                              right: -24,
                              child: RawMaterialButton(
                                padding: const EdgeInsets.all(12.0),
                                fillColor: const Color(0xFFF5F6F9),
                                shape: const CircleBorder(),
                                elevation: 3.0,
                                child: Icon(
                                  FontAwesomeIcons.pen,
                                  color: Colors.pink.shade300,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return ProfileImageUploaderSheet(
                                        galleryOnTap: () {
                                          takePhoto(ImageSource.gallery);
                                          Navigator.pop(context);
                                        },
                                        cameraOnTap: () {
                                          takePhoto(ImageSource.camera);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height * 2 / 5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int i = 0; i < 4; i++)
                                TextField(
                                  keyboardType: signUpKeyboards[i],
                                  obscureText: i == 3 ? true : false,
                                  cursorColor: Colors.pink,
                                  cursorRadius: const Radius.circular(20.0),
                                  cursorWidth: 10.0,
                                  cursorHeight: 22.0,
                                  decoration: kTextFieldDecoration.copyWith(
                                    hintText: signUpFields[i],
                                  ),
                                  onChanged: signUpFunctions[i],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (MediaQuery.of(context).viewInsets.bottom == 0)
                      TextButton(
                        onPressed: () {
                          if (email == null ||
                              username == null ||
                              name == null ||
                              password == null) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.SCALE,
                              title: 'Empty Field(s)',
                              btnOkOnPress: () {},
                            ).show();
                            return;
                          }

                          if (_imageFile == null) {
                            AwesomeDialog(
                                context: context,
                                dialogType: DialogType.WARNING,
                                animType: AnimType.SCALE,
                                btnOkText: 'Yes',
                                btnCancelText: 'No',
                                title: 'No Profile Image',
                                desc:
                                    'Do you wish to Sign Up without any profile image ?',
                                btnOkOnPress: () {
                                  signUp();
                                },
                                btnCancelOnPress: () {
                                  return;
                                }).show();
                          } else {
                            signUp();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green.shade100,
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.green,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
