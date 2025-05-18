// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controller/NetworkController.dart';
import '../services/SharedPrefs.dart';
import '../themes/ThemeController.dart';
import '../locale/LocaleController.dart';

class VideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? url360p;
  final String? url720p;
  final String? url1080p;
  const VideoPlayer({
    super.key,
    required this.videoUrl,
    this.url360p,
    this.url720p,
    this.url1080p,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String _currentQuality = 'Auto'.tr;
  final NetworkController networkController = Get.find<NetworkController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  late SharedPrefs sharedPrefs;

  @override
  void initState() {
    super.initState();
    sharedPrefs = SharedPrefs.instance;
    _initializePlayer(widget.videoUrl);
  }

  Future<void> _initializePlayer(String url) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      // Check connectivity
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == sharedPrefs.prefs.getBool('isConnected')) {
        throw Exception("No internet connection".tr);
      }

      // Dispose previous controllers if they exist
      await _videoPlayerController?.dispose();
      _chewieController?.dispose();

      // Initialize video player
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController.initialize();

      // Initialize Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: true,
        customControls: const MaterialControls(),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(errorMessage),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _initializePlayer(url),
                  child: Text('Retry'.tr),
                ),
              ],
            ),
          );
        },
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
              onTap: (BuildContext context) => _showQualityDialog(),
              iconData: Icons.hd,
              title: 'Select Video Quality'.tr,
            ),
            OptionItem(
              onTap: (BuildContext context) => _showSpeedDialog(),
              iconData: Icons.speed,
              title: 'Playback Speed'.tr,
            ),
          ];
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Video Quality'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Auto'.tr),
              onTap: () {
                _changeQuality('Auto'.tr);
                Navigator.pop(context);
              },
            ),
            if (widget.url360p != null)
              ListTile(
                title: Text('360p'.tr),
                onTap: () {
                  _changeQuality('360p'.tr);
                  Navigator.pop(context);
                },
              ),
            if (widget.url720p != null)
              ListTile(
                title: Text('720p'.tr),
                onTap: () {
                  _changeQuality('720p'.tr);
                  Navigator.pop(context);
                },
              ),
            if (widget.url1080p != null)
              ListTile(
                title: Text('1080p'.tr),
                onTap: () {
                  _changeQuality('1080p'.tr);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Playback Speed'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('0.5x'),
              onTap: () {
                _changePlaybackSpeed(0.5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('1.0x'),
              onTap: () {
                _changePlaybackSpeed(1.0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('1.5x'),
              onTap: () {
                _changePlaybackSpeed(1.5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('2.0x'),
              onTap: () {
                _changePlaybackSpeed(2.0);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changePlaybackSpeed(double speed) {
    if (_chewieController != null) {
      _videoPlayerController.setPlaybackSpeed(speed);
    }
  }

  Future<void> _changeQuality(String quality) async {
    if (_videoPlayerController.value.isPlaying) {
      await _videoPlayerController.pause();
    }

    String? newUrl;
    switch (quality) {
      case '360p':
        newUrl = widget.url360p;
        break;
      case '720p':
        newUrl = widget.url720p;
        break;
      case '1080p':
        newUrl = widget.url1080p;
        break;
      default:
        newUrl = widget.videoUrl;
    }

    if (newUrl != null && newUrl.isNotEmpty) {
      setState(() {
        _currentQuality = quality;
      });
      await _initializePlayer(newUrl);
    } else {
      Get.snackbar(
        'Error'.tr,
        'Failed to load video: this quality is not available'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Video Player'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : _hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 50),
                          const SizedBox(height: 16),
                          Text(_errorMessage ?? 'Failed to load video'.tr),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _initializePlayer(
                              _currentQuality == 'Auto'.tr
                                  ? widget.videoUrl
                                  : _getUrlForQuality(_currentQuality) ??
                                      widget.videoUrl,
                            ),
                            child: Text('Retry'.tr),
                          ),
                        ],
                      )
                    : AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: Chewie(controller: _chewieController!),
                      ),
          ),
        ),
      ),
    );
  }

  String? _getUrlForQuality(String quality) {
    switch (quality) {
      case '360p':
        return widget.url360p;
      case '720p':
        return widget.url720p;
      case '1080p':
        return widget.url1080p;
      default:
        return widget.videoUrl;
    }
  }
}