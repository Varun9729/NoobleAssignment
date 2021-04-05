import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotifytiktok/main.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:spotifytiktok/pages/musicPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlayListPage extends StatefulWidget {
  @override
  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  var futureFeaturedPlaylists;

  getFeaturedPlaylists() async {
    var response = await http.get(
      Uri.parse("https://api.spotify.com/v1/browse/featured-playlists"),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json",
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(response.reasonPhrase);
      throw Exception();
    }
  }

  @override
  void initState() {
    super.initState();
    futureFeaturedPlaylists = getFeaturedPlaylists();
  }

  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [Vx.blue900, Vx.red400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          AppBar(
            title: "Trending Playlists"
                .text
                .white
                .xl2
                .bold
                .center
                .heightRelaxed
                .wide
                .uppercase
                .make(),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          FutureBuilder(
            future: futureFeaturedPlaylists,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Center(child: Text('Press button to start'));
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.white),
                  );
                default:
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));
                  else
                    return Center(
                      child: CarouselSlider.builder(
                        itemCount: snapshot.data['playlists']['items'].length,
                        options: CarouselOptions(
                            height: 450,
                            viewportFraction: 0.75,
                            aspectRatio: 16 / 9,
                            initialPage: 0,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal),
                        itemBuilder: (context, index) {
                          return InkWell(
                            splashColor: Colors.white,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (builder) {
                                return MusicPage(
                                    id: snapshot.data['playlists']['items']
                                            [index]['id']
                                        .toString());
                              }));
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(0, 2),
                                            blurRadius: 2,
                                            color:
                                                Colors.black.withOpacity(0.2))
                                      ],
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          snapshot.data['playlists']['items']
                                              [index]['images'][0]['url'],
                                        ),
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                ),
                                Positioned(
                                  bottom: 8.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.play,
                                        color: Colors.white,
                                        size: 30.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
              }
            },
          ),
        ],
      ),
    );
  }
}
