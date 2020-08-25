import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:tapioca/tapioca.dart';

import 'package:path_provider/path_provider.dart';
import 'package:video_filter_trimmer/main.dart';

import 'package:video_player/video_player.dart';

class VideoFilter extends StatefulWidget {
  static const routeName = "/video_filter";
  final String path;
  VideoFilter(this.path);
  @override
  _VideoFilterState createState() => _VideoFilterState();
}

class _VideoFilterState extends State<VideoFilter> {
  VideoPlayerController _controller;
  var video;
  List tapiocaBalls = [
    [TapiocaBall.filter(Filters.blue)],
    [TapiocaBall.filter(Filters.pink)],
    [TapiocaBall.filter(Filters.white)],
    [TapiocaBall.textOverlay("hello", 100, 10, 50, Colors.black)],
  ];

  @override
  void initState() {
    super.initState();
    video = File(widget.path);
    _controller = VideoPlayerController.file(video)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });

    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Trimmer"),
        actions: [
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return VideoPlaying(video.path, false);
                }));
              }),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _controller.value.initialized
                ? AspectRatio(
                    aspectRatio: width / (height - 88),
                    child: VideoPlayer(_controller),
                  )
                : Container(
                    child: Text("Video Not Loaded"),
                  ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < 5; i++) ...[
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: InkWell(
                          onTap: () async {
                            var tempDir = await getTemporaryDirectory();
                            final path = '${tempDir.path}/result.mp4';
                            final cup =
                                Cup(Content(widget.path), tapiocaBalls[i]);
                            cup.suckUp(path).then((_) {
                              setState(() {
                                video = File(path);
                                _controller = VideoPlayerController.file(video)
                                  ..initialize().then((_) {
                                    setState(() {
                                      _controller.play();
                                    });
                                  });
                              });
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(8)),
                            width: 0.2 * width,
                            height: 0.13 * height,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              SizedBox(
                height: 0.02 * height,
              )
            ],
          ),
        ],
      ),
    );
  }
}
