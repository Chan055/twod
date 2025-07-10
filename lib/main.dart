import 'package:dtwo/pages/history.dart';
import 'package:dtwo/pages/home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:dtwo/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'IbarraRealNova',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF2B2D42)),
          bodyMedium: TextStyle(color: Color(0xFF2B2D42)),
        ),
        scaffoldBackgroundColor: Color(0xFF2B2D42),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        "/": (context) => LoginPage(),
        "/home": (context) => Home(),
        "/history": (context) => HistoryPage(),
      },
    );
  }
}
