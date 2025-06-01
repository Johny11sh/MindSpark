// ignore_for_file: file_names, library_private_types_in_public_api
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../themes/Themes.dart';
import '../themes/ThemeController.dart';
import 'package:get/get.dart';
import '../view/NavBar.dart';

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
  bool _isInitialized = false;
  bool _isError = false;
  String? _errorMessage;
  final ThemeController themeController = Get.find<ThemeController>();
  bool _isDisposed = false;
  String _currentQuality = 'Auto';
  AudioPlayer audio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Pause audio and hide navbar when entering video player
    audio.pause();
    NavBarState.isNavBarVisible = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed) return;

    try {
      setState(() {
        _isInitialized = false;
        _isError = false;
      });

      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("No internet connection".tr);
      }

      // Use the current quality URL or default to videoUrl
      final currentUrl = _currentQuality == 'Auto' 
          ? widget.videoUrl 
          : _getQualityUrl(_currentQuality);

      // Initialize video player with buffering configuration
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(currentUrl!),
        httpHeaders: const {'Accept': '*/*', 'Connection': 'keep-alive'},
      )
        ..setLooping(false)
        ..setVolume(1.0);

      // Add error listener
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.hasError && !_isDisposed) {
          setState(() {
            _isError = true;
            _errorMessage = _videoPlayerController.value.errorDescription;
          });
        }
      });

      // Initialize with timeout
      await _videoPlayerController.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Video initialization timed out');
        },
      );

      if (_isDisposed) return;

      // Initialize Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoInitialize: true,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        allowedScreenSleep: false,
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
        materialProgressColors: _getProgressColors(),
        additionalOptions: (context) => _buildAdditionalOptions(),
      );

      if (!_isDisposed) {
        setState(() {
          _isInitialized = true;
          _isError = false;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
      debugPrint('Error initializing video player: $e');
    }
  }

  String? _getQualityUrl(String quality) {
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

  List<OptionItem> _buildAdditionalOptions() {
    final options = <OptionItem>[];
    
    // Only add quality option if we have multiple qualities available
    if (_hasMultipleQualities()) {
      options.add(
        OptionItem(
          onTap: (context) => _showQualityDialog(Get.context!),
          iconData: Icons.hd,
          title: 'Quality (${_currentQuality})'.tr,
        ),
      );
    }
    
    return options;
  }

  bool _hasMultipleQualities() {
    int count = 1; // Auto is always available
    if (widget.url360p != null && widget.url360p!.isNotEmpty) count++;
    if (widget.url720p != null && widget.url720p!.isNotEmpty) count++;
    if (widget.url1080p != null && widget.url1080p!.isNotEmpty) count++;
    return count > 1;
  }

  Future<void> _showQualityDialog(BuildContext context) async {
    final qualityOptions = <String>['Auto'];
    if (widget.url360p != null && widget.url360p!.isNotEmpty) qualityOptions.add('360p');
    if (widget.url720p != null && widget.url720p!.isNotEmpty) qualityOptions.add('720p');
    if (widget.url1080p != null && widget.url1080p!.isNotEmpty) qualityOptions.add('1080p');

    if (qualityOptions.length <= 1) return;

    final newQuality = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Quality'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: qualityOptions.map((quality) => ListTile(
            title: Text(quality.tr),
            trailing: _currentQuality == quality ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, quality),
          )).toList(),
        ),
      ),
    );

    if (newQuality != null && newQuality != _currentQuality) {
      await _changeQuality(newQuality);
    }
  }

  Future<void> _changeQuality(String quality) async {
    if (_isDisposed) return;

    try {
      setState(() {
        _isInitialized = false;
        _currentQuality = quality;
      });

      final wasPlaying = _videoPlayerController.value.isPlaying;
      final position = _videoPlayerController.value.position;

      await _videoPlayerController.pause();
      await _videoPlayerController.dispose();
      _chewieController?.dispose();

      await _initializePlayer();

      if (wasPlaying && !_isDisposed) {
        await _videoPlayerController.seekTo(position);
        await _videoPlayerController.play();
      }
    } catch (e) {
      debugPrint('Error changing quality: $e');
      if (!_isDisposed) {
        Get.snackbar(
          'Error'.tr,
          'Failed to change video quality'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  ChewieProgressColors _getProgressColors() {
    return ChewieProgressColors(
      playedColor: themeController.initialTheme == Themes.customLightTheme
          ? const Color.fromARGB(255, 210, 209, 224)
          : const Color.fromARGB(255, 40, 41, 61),
      bufferedColor: themeController.initialTheme == Themes.customLightTheme
          ? const Color.fromARGB(255, 40, 41, 61)
          : const Color.fromARGB(255, 210, 209, 224),
      handleColor: themeController.initialTheme == Themes.customLightTheme
          ? const Color.fromARGB(255, 40, 41, 61)
          : const Color.fromARGB(255, 210, 209, 224),
      backgroundColor: themeController.initialTheme == Themes.customLightTheme
          ? const Color.fromARGB(255, 40, 41, 61)
          : const Color.fromARGB(255, 210, 209, 224),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializePlayer,
            child: Text('Retry'.tr),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    // Resume audio and show navbar when leaving video player
    audio.resume();
    NavBarState.isNavBarVisible = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: themeController.initialTheme == Themes.customLightTheme
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61),
        body: SafeArea(
          child: Center(
            child: _isError
                ? _buildErrorWidget(_errorMessage ?? 'Failed to load video'.tr)
                : _isInitialized && _chewieController != null
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: Chewie(controller: _chewieController!),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
          ),
        ),
      ),
    );
  }
}
