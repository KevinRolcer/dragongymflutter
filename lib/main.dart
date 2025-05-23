import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'service/usuario_provider.dart';

import 'login.dart';
import 'screens/home.dart';
import 'screens/promo.dart';
import 'screens/perfil.dart';
import 'pin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await initializeDateFormatting('es_ES', null);

  runApp(
    ChangeNotifierProvider(
      create: (_) => UsuarioProvider(),
      child: const MyApp(),
    ),
  );
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
        '/promo': (context) => PromoScreen(),
        '/perfil': (context) => PerfilScreen(),
      },
    );
  }
}
