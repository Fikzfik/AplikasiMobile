import 'package:fikzuas/pages/Auth/LoginPage.dart';
import 'package:fikzuas/pages/Auth/RegisterPage.dart';
import 'package:fikzuas/pages/Home/HomePage.dart';
import 'package:fikzuas/pages/Joki/JasaJokiPage.dart';
import 'package:fikzuas/pages/Playstastion/WarnetSelectionPSPage.dart';
import 'package:fikzuas/pages/TopUp/TopUpGameSelectionPage.dart';
import 'package:fikzuas/pages/Warnet/WarnetSelectionPage.dart';
import 'package:fikzuas/pages/home/history/HistoryPage.dart';
import 'package:fikzuas/pages/home/profile/SettingsPage.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/home': (context) => HomePage(),
      '/login': (context) => LoginPage(),
      '/register': (context) => RegisterPage(),
      '/warnet_selection': (context) => WarnetSelectionPage(),
      '/topup': (context) => TopUpGameSelectionPage(),
      '/joki': (context) => JasaJokiPage(),
      '/settings': (context) => SettingsPage(),
      '/logout': (context) => LoginPage(),
      '/sewaps': (context) => WarnetSelectionPSPage(),
      '/history': (context) => HistoryPage(
            refreshOnLoad: ModalRoute.of(context)?.settings.arguments != null &&
                (ModalRoute.of(context)!.settings.arguments as Map?)?
                        ['refreshOnLoad'] ==
                    true,
          ),
    };
  }
}