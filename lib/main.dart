import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home.dart';
import 'pin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/pin': (context) => PinScreen(),
      },
    );
  }
}
