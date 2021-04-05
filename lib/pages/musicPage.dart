import 'dart:convert';
import 'dart:io';
import 'package:velocity_x/velocity_x.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotifytiktok/pages/musicPlayer.dart';
import 'package:spotifytiktok/main.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

PageController pgcontroller = PageController();

class MusicPage extends StatefulWidget {
  final String id;
  MusicPage({@required this.id});

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  //
  //Data Stuff
  var tracksData;

  //Get tracks function
  getTracksData() async {
    var response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/${widget.id}/tracks'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json",
      },
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var parsedData = [];
      for (var i = 0; i < body['items'].length; i++) {
        if (body['items'][i]['track']['id'] == null ||
            body['items'][i]['track']['preview_url'] == null) {
          continue;
        } else {
          var deeperResponse = await http.get(
            Uri.parse(
                'https://api.spotify.com/v1/tracks/${body['items'][i]['track']['id']}'),
            headers: {
              HttpHeaders.authorizationHeader: "Bearer $accessToken",
              HttpHeaders.acceptHeader: "application/json",
              HttpHeaders.contentTypeHeader: "application/json",
            },
          );
          if (deeperResponse.statusCode == 200) {
            var deeperBody = jsonDecode(deeperResponse.body);
            var id = deeperBody['id'];
            var name = deeperBody['name'];
            var imag = deeperBody['album']['images'][0]['url'];
            var previewUrl = deeperBody['preview_url'];
            parsedData.add({
              'trackId': id,
              'name': name,
              'imageUrl': imag,
              'previewUrl': previewUrl
            });
          } else {
            print(deeperResponse.reasonPhrase);
            throw Exception();
          }
        }
      }
      return parsedData;
    } else {
      print(response.reasonPhrase);
      throw Exception();
    }
  }

  @override
  void initState() {
    super.initState();

    // Data stuff
    tracksData = getTracksData();
  }

  @override
  void dispose() {
    pgcontroller.dispose();
    super.dispose();
  }

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
          FutureBuilder(
            future: tracksData,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Center(child: Text('Press button to start'));
                case ConnectionState.waiting:
                  return Center(
                      child: LiquidLinearProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(Colors.pink),
              borderColor: Colors.red,
              borderWidth: 5.0,
              direction: Axis.vertical,
            ),);
                default:
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));
                  else
                    return PageView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: pgcontroller,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(160),
                                    bottomRight: Radius.circular(160),
                                  ),
                                  image: DecorationImage(
                                      image: NetworkImage(snapshot.data[index]
                                              ['imageUrl']
                                          .toString()),
                                      fit: BoxFit.fitHeight),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      snapshot.data[index]['name'].toString(),
                                      textScaleFactor: 2.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: PlayerWidget(
                                url: snapshot.data[index]['previewUrl']
                                    .toString(),
                              ),
                            ),
                          ],
                        );
                      },
                    );
              }
            },
          ),
        ],
      ),
    );
  }
}
