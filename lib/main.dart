import 'package:flutter/material.dart';

import 'ui/game_screen.dart';

void main() {
  runApp(const AsteroidsApp());
}

class AsteroidsApp extends StatelessWidget {
  const AsteroidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Asteroids',
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}
