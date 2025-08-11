import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../extensions/colors.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Widgets.dart';
import 'package:video_player/video_player.dart';

import '../../extensions/extension_util/context_extensions.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class CustomerSupportDetailsScreen extends StatefulWidget {
  final String video;
  final String image;

  CustomerSupportDetailsScreen(this.video, this.image);

  @override
  State<StatefulWidget> createState() {
    return _CustomerSupportDetailsScreenState();
  }
}

class _CustomerSupportDetailsScreenState extends State<CustomerSupportDetailsScreen> {
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
    print("当前进入 customer_support_details_screen.dart 页面");
    if (widget.video.isNotEmpty) initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 = VideoPlayerController.networkUrl(Uri.parse(widget.video));
    await Future.wait([_videoPlayerController1.initialize()]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
      progressIndicatorDelay: bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
      hideControlsTimer: const Duration(seconds: 1),
      showOptions: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: ColorUtils.colorPrimary,
        handleColor: ColorUtils.colorPrimary,
        backgroundColor: textSecondaryColorGlobal,
        bufferedColor: textSecondaryColorGlobal,
      ),
      // autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (widget.video.isNotEmpty && widget.video != "null") ? black : Colors.transparent,
      appBar: commonAppBarWidget("", showBack: true),
      body: (widget.video.isNotEmpty && widget.video != "null")
          ? AspectRatio(
              aspectRatio: 9 / 16,
              child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : loaderWidget(),
            ).center()
          : CachedNetworkImage(
              width: context.width(),
              height: context.height(),
              imageUrl: widget.image,
              fit: BoxFit.cover,
            ).center().paddingAll(10).center(),
    );
  }
}
