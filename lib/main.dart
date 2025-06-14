import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/pages/Warnet/WarnetSelectionPage.dart';
import 'package:fikzuas/pages/Warnet/WarnetSelectionPSPage.dart';
import 'package:fikzuas/pages/TopUp/TopUpGameSelectionPage.dart';
import 'package:fikzuas/pages/HomePage.dart';
import 'package:fikzuas/pages/JasaJokiPage.dart';
import 'package:fikzuas/pages/RegisterPage.dart';
import 'package:fikzuas/pages/LoginPage.dart';
import 'package:fikzuas/pages/DesignPage.dart';
import 'package:fikzuas/pages/SettingsPage.dart';
import 'package:fikzuas/pages/HistoryPage.dart';

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
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
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFFF9FAFE),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF7C3AED),
          background: Color(0xFFF9FAFE),
          surface: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(
              fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 14),
            textStyle: TextStyle(
                fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF1F2937),
        scaffoldBackgroundColor: Color(0xFF111827),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF7C3AED),
          background: Color(0xFF111827),
          surface: Color(0xFF1F2937),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(
              fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 14),
            textStyle: TextStyle(
                fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/design': (context) => Designpage(),
        '/warnet_selection': (context) => WarnetSelectionPage(),
        '/topup': (context) => TopUpGameSelectionPage(),
        '/joki': (context) => JasaJokiPage(),
        '/settings': (context) => SettingsPage(),
        '/logout': (context) => LoginPage(),
        '/sewaps': (context) => WarnetSelectionPSPage(),
        '/history': (context) => HistoryPage(
              refreshOnLoad:
                  ModalRoute.of(context)?.settings.arguments != null &&
                      (ModalRoute.of(context)!.settings.arguments
                              as Map?)?['refreshOnLoad'] ==
                          true,
            ),
      },
    );
  }
}