import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/core/themes/theme_provider.dart';
import 'package:fikzuas/core/themes/app_theme.dart';
import 'package:fikzuas/core/routes/app_routes.dart';

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/home',
      routes: AppRoutes.routes,
    );
  }
}