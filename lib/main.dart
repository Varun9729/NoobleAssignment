import 'package:flutter/material.dart';
import 'package:spotifytiktok/pages/playlistPage.dart';

var accessToken = 'YOUR ACCESS TOKEN FROM POSTMAN HERE';
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
