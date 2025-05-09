import 'package:flutter/material.dart';
import 'package:fikzuas/pages/BokingPage.dart';
import 'package:fikzuas/pages/HomePage.dart';
import 'package:fikzuas/pages/JasaJokiPage.dart';
import 'package:fikzuas/pages/RegisterPage.dart';
import 'package:fikzuas/pages/LoginPage.dart';
import 'package:fikzuas/pages/DesignPage.dart';
import 'package:fikzuas/pages/SewaPSPage.dart';
import 'package:fikzuas/pages/TopUpPage.dart';
import 'package:fikzuas/pages/SettingsPage.dart';
import 'package:provider/provider.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1A1D40),
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A1D40),
          secondary: Colors.purpleAccent,
          background: Colors.grey,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
        cardTheme:  CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2C2F50),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2C2F50),
          secondary: Colors.purpleAccent,
          background: Color(0xFF121212),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
        cardTheme:  CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/design': (context) => Designpage(),
        '/boking': (context) => BookingPage(),
        '/sewaps': (context) => SewaPsPage(),
        '/topup': (context) => TopUpPage(),
        '/joki': (context) => JasaJokiPage(),
        '/settings': (context) => SettingsPage(),
        '/logout': (context) => LoginPage(),
      },
    );
  }
}