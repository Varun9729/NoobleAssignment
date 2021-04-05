import 'package:flutter/material.dart';
import 'package:spotifytiktok/pages/playlistPage.dart';

var accessToken = 'BQA8bB3jiewxrI4wSTccQu1IdFlyxDX-vwDUQZXoABcwL-8fMtQXLAGFKmdc5Lb3LkGUwVieyyD1ukuH7N0NlAdDD1G4cXgEAor1abK42tKuL1Jy0WISLuhTuwS0kCzj_-Q3lyhIwJCxhb1CcNmUFd2FAhvAVyLnCjbwZA';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'OpenSans'),
      home: PlayListPage(),
    );
  }
}
