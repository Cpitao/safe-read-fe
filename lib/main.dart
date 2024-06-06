import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferead/api.dart';
import 'package:saferead/key_manager.dart';

import 'pages/document_page.dart';
import 'pages/library_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/shelf_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BackendAPI(),
      child: ChangeNotifierProvider(
        create: (context) => KeyManager(),
        child: const App(),
      ),
    )
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color.fromARGB(255, 0, 140, 255),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 0, 140, 255),
      ),
    );
    return Consumer<BackendAPI>(
      builder:(context, api, child) =>
        MaterialApp(
          home: api.status == AuthStatus.authenticated ? LibraryPage(api) : LoginPage(api),
          routes: <String, WidgetBuilder> {
            '/shelf': (BuildContext context) => ShelfPage(api),
            '/document': (BuildContext context) => DocumentPage(api),
            '/register': (BuildContext context) => RegisterPage(api),
            '/login': (BuildContext context) => LoginPage(api),
          },
          theme: theme,
          debugShowCheckedModeBanner: false,
        ),
      );
  }
}
