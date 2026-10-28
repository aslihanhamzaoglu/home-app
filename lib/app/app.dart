import 'package:flutter/material.dart';

import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The app's name, not translated.
      title: 'Ev',
      theme: lightTheme,
      darkTheme: darkTheme,
      // Sign-in, routing and the Household screens come in later tickets.
      home: const Scaffold(),
    );
  }
}
