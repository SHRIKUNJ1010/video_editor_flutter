import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_filter_trimmer/video_filters.dart';
import 'package:video_filter_trimmer/video_trimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:tapioca/tapioca.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VideoPlaying(
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          true),
    );
  }
}

class VideoPlaying extends StatefulWidget {
  final String path;
  final bool network;
  VideoPlaying(this.path, this.network);
  @override
  _VideoPlayingState createState() => _VideoPlayingState();
}

class _VideoPlayingState extends State<VideoPlaying> {
  VideoPlayerController _controller;
  final Trimmer _trimmer = Trimmer();
  var video;

  void addWaterMark(String pathes) async {
    final imageBitmap = (await rootBundle.load("assets/flynix_water_mark.png"))
        .buffer
        .asUint8List();

    var tapiocaBalls = [TapiocaBall.imageOverlay(imageBitmap, 580, 1200)];

    var tempDir = await getTemporaryDirectory();
    final paths = '${tempDir.path}/result.mp4';
    final cup = Cup(Content(pathes), tapiocaBalls);
    cup.suckUp(paths).then((_) {
      GallerySaver.saveVideo(paths, albumName: "new").whenComplete(() {
        print("video saved");
      });
      setState(() {
        video = File(paths);
        _controller = VideoPlayerController.file(video)
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {
              _controller.play();
            });
            _controller.setLooping(true);
          });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.network) {
      _controller = VideoPlayerController.network(widget.path)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            _controller.play();
          });
        });
    } else {
      addWaterMark(widget.path);
      //File file = File(widget.path);
      //video = file;
      // Timer(Duration(milliseconds: 5000), () {
      //   _controller = VideoPlayerController.file(video)
      //     ..initialize().then((_) {
      //       // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      //       setState(() {
      //         _controller.play();
      //       });
      //       _controller.setLooping(true);
      //     });
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _controller.value.initialized
                ? AspectRatio(
                    aspectRatio: width / height,
                    child: VideoPlayer(_controller),
                  )
                : Container(
                    child: Text("Video Not Loaded"),
                  ),
          ),
          Positioned(
            left: 0.02 * width,
            top: 0.935 * height,
            child: InkWell(
              child: Icon(
                Icons.add_circle,
                color: Colors.white,
                size: 0.1 * width,
              ),
              onTap: () async {
                video = await FilePicker.getFile(type: FileType.video);
                print("--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-hello ");
                print(video.path);
                addWaterMark(video.path);

                // Timer(Duration(milliseconds: 5000), () {
                //   _controller = VideoPlayerController.file(video)
                //     ..initialize().then((_) {
                //       // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                //       setState(() {
                //         _controller.play();
                //       });
                //       _controller.setLooping(true);
                //     });
                // });
              },
            ),
          ),
          Positioned(
            left: 0.87 * width,
            top: 0.85 * height,
            //left: 0.9 * Get.width,
            //top: 0.8 * Get.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  child: Icon(
                    Icons.filter_center_focus,
                    color: Colors.white,
                    size: 0.1 * width,
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return VideoFilter(video.path);
                    }));
                  },
                ),
                SizedBox(
                  height: 0.02 * height,
                ),
                InkWell(
                  child: Icon(
                    Icons.transform,
                    color: Colors.white,
                    size: 0.1 * width,
                  ),
                  onTap: () async {
                    await _trimmer.loadVideo(videoFile: video);
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return TrimmerView(_trimmer);
                    }));
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }
}
