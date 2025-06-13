import 'package:fikzuas/FixedStoreApp.dart';
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
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
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
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
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
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
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
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
      ),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/fixedstore', // 👉 Ini diarahkan ke FixeHomePage
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
        '/fixedstore': (context) => FixedStore(), // 👉 Tambahkan ini
        '/history': (context) => HistoryPage(
              refreshOnLoad: ModalRoute.of(context)!.settings.arguments != null &&
                  (ModalRoute.of(context)!.settings.arguments as Map)['refreshOnLoad'] == true,
            ),
      },
    );
  }
}
