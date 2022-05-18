import 'package:chat_app/Screens/chat_details.dart';
import 'package:chat_app/Screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/friends_screen.dart';
import 'Screens/main_screen.dart';
import 'Screens/profile_screen.dart';
import 'Screens/search_screen.dart';
import 'Screens/signup_screen.dart';
import 'Screens/splash_screen.dart';
import 'data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => Data(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.pink,
          selectionColor: Colors.grey,
        ),
      ),
      // Change home to SignUpScreen()
      home: const SplashScreen(),
      routes: {
        'main': (context) => const MainScreen(),
        'SplashScreen': (context) => const SplashScreen(),
        'FriendsScreen': (context) => const FriendsScreen(),
        'Chat Details': (context) => ChatDetail(
              Provider.of<Data>(context, listen: true).getChatList[0],
            ),
        'Profile': (context) => ProfileScreen(),
        'LogIn': (context) => LogInScreen(),
        'SignUp': (context) => SignUpScreen(),
        'search': (context) => SearchScreen(),
      },
      // home: MainScreen(),
    );
  }
}
