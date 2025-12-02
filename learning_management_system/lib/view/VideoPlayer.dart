// ignore_for_file: file_names, library_private_types_in_public_api, unrelated_type_equality_checks, avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/controller/LikesController.dart';
import 'package:like_button/like_button.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../controller/ProfileController.dart';
import '../core/classes/ReviewsPage.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/CustomRatingDialog.dart';
import '../core/function/buildRatingBar.dart';
import '../core/function/noDataLottie.dart';
import '../locale/LocaleController.dart';
import '../services/SharedPrefs.dart';
import '../themes/Themes.dart';
import '../themes/ThemeController.dart';
import '../controller/NetworkController.dart';
import 'package:get/get.dart';
import 'NavBar.dart';

class VideoPlayer extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final String videoUrl;
  final String? url360p;
  final String? url720p;
  final String? url1080p;
  const VideoPlayer({
    super.key,
    required this.videoData,
    required this.videoUrl,
    this.url360p,
    this.url720p,
    this.url1080p,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  Set<int> expandedReviews = {};
  final TextEditingController reportController = TextEditingController();
  final LikesController likesController = Get.find<LikesController>();
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isError = false;
  String? _errorMessage;
  final NetworkController networkController = Get.find<NetworkController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final ProfileController profileController = Get.find<ProfileController>();

  bool _isDisposed = false;
  String _currentQuality = 'Auto';
  late bool IsLiked;
  late bool isDisLiked;
  AudioPlayer audio = AudioPlayer();
  int isWatched = 0;
  bool isRated = false;
  late String token;
  late SharedPrefs sharedPrefs;
  Map<int, bool> ratedLessons = {};
  List<String> ReportList = [];

  double? newUserRating;
  List<Map<String, dynamic>> newFeaturedRating = [];
  Map<String, dynamic> newBreakingDown = {};
  String? newCTRLRating;

  bool report1 = false;
  bool report2 = false;
  bool report3 = false;
  bool? isConnected;
  // late bool IsHelpful;
  // late bool IsUnHelpful;
  Map<int, bool> helpfulStates = {};
  Map<int, bool> unhelpfulStates = {};

  bool _hasCountedView = false;

  bool _isFullScreen = false;
  VoidCallback? _chewieListener;

  bool _isInitializing = false;
  VoidCallback? _videoListener;

  bool _areBarsVisible = false;

  void Animations() {
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _areBarsVisible = true;
        });
      }
    });
  }

  Future<void> incrementViews(String id) async {
    final url = Uri.parse('$mainIP/api/incrementviews/$id');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        widget.videoData["views"] = data['views'];
      });
    } else {
      print('Error : ${response.body}');
    }
  }

  Future<void> loadRatedLessons() async {
    final storedMap = await sharedPrefs.loadMap("ratedLessons");
    setState(() {
      ratedLessons = storedMap;
    });
  }

  @override
  void initState() {
    super.initState();

    Animations();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializePlayer();
    _initSharedPreferences();
    likesController.onInit();

    token = sharedPrefs.prefs.getString("token")!;
    profileController.getProfileData();

    IsLiked = widget.videoData["isLiked"] == true;
    isDisLiked = widget.videoData["isDisliked"] == true;
    loadRatedLessons();
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  // Future<void> _initializePlayer() async {
  //   if (_isDisposed) return;

  //   try {
  //     setState(() {
  //       _isInitialized = false;
  //       _isError = false;
  //     });

  //     final connectivityResult = await Connectivity().checkConnectivity();
  //     if (connectivityResult == ConnectivityResult.none) {
  //       throw Exception("No internet connection".tr);
  //     }

  //     final currentUrl =
  //         _currentQuality == 'Auto'
  //             ? widget.videoUrl
  //             : _getQualityUrl(_currentQuality);

  //     _videoPlayerController =
  //         VideoPlayerController.networkUrl(
  //             Uri.parse(currentUrl!),
  //             httpHeaders: const {'Accept': '*/*', 'Connection': 'keep-alive'},
  //           )
  //           ..setLooping(false)
  //           ..setVolume(1.0);

  //     _videoPlayerController.addListener(() {
  //       if (_videoPlayerController.value.hasError && !_isDisposed) {
  //         setState(() {
  //           _isError = true;
  //           _errorMessage = _videoPlayerController.value.errorDescription;
  //         });
  //       }
  //     });

  //     _videoPlayerController.addListener(() {
  //       if (_videoPlayerController.value.isPlaying && !_hasCountedView) {
  //         incrementViews(widget.videoData["id"].toString());
  //         _hasCountedView = true;
  //       }
  //     });

  //     await _videoPlayerController.initialize().timeout(
  //       const Duration(seconds: 15),
  //       onTimeout: () {
  //         throw TimeoutException('Video initialization timed out');
  //       },
  //     );

  //     if (_isDisposed) return;

  //     // Initialize Chewie controller
  //     _chewieController = ChewieController(
  //       videoPlayerController: _videoPlayerController,
  //       aspectRatio: _videoPlayerController.value.aspectRatio,
  //       autoInitialize: true,
  //       autoPlay: false,
  //       looping: false,
  //       showControlsOnInitialize: true,
  //       allowFullScreen: true,
  //       allowMuting: true,
  //       allowedScreenSleep: false,
  //       errorBuilder: (context, errorMessage) {
  //         return _buildErrorWidget(errorMessage);
  //       },
  //       materialProgressColors: _getProgressColors(),
  //       additionalOptions: (context) => _buildAdditionalOptions(),
  //     );

  //     _chewieListener ??= () {
  //       if (!mounted) return;
  //       final isFs = _chewieController?.isFullScreen ?? false;
  //       if (isFs != _isFullScreen) {
  //         setState(() => _isFullScreen = isFs);
  //       }
  //     };
  //     _chewieController?.addListener(_chewieListener!);

  //     if (!_isDisposed) {
  //       setState(() {
  //         _isInitialized = true;
  //         _isError = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (!_isDisposed) {
  //       setState(() {
  //         _isError = true;
  //         _errorMessage = e.toString();
  //       });
  //     }
  //     debugPrint('Error initializing video player: $e');
  //   }
  // }

  Future<void> _initializePlayer() async {
    if (_isDisposed) return;
    if (_isInitialized || _isInitializing == true) return;
    _isInitializing = true;

    try {
      setState(() {
        _isInitialized = false;
        _isError = false;
        _errorMessage = null;
      });

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("No internet connection".tr);
      }

      final currentUrl =
          _currentQuality == 'Auto'
              ? widget.videoUrl
              : _getQualityUrl(_currentQuality);
      if (currentUrl == null || currentUrl.isEmpty) {
        throw Exception("Video URL is invalid");
      }

      _videoPlayerController =
          VideoPlayerController.networkUrl(
              Uri.parse(currentUrl),
              httpHeaders: const {'Accept': '*/*', 'Connection': 'keep-alive'},
            )
            ..setLooping(false)
            ..setVolume(1.0);

      _videoPlayerController.removeListener(_videoListener ?? () {});
      _videoListener = () {
        if (_isDisposed) return;
        if (_videoPlayerController.value.hasError) {
          debugPrint(
            'VideoPlayer error: ${_videoPlayerController.value.errorDescription}',
          );
          if (!_isDisposed) {
            setState(() {
              _isError = true;
              _errorMessage =
                  _videoPlayerController.value.errorDescription ??
                  'Unknown video error';
            });
          }
        }
        if (_videoPlayerController.value.isPlaying && !_hasCountedView) {
          incrementViews(widget.videoData["id"].toString());
          _hasCountedView = true;
        }
      };
      _videoPlayerController.addListener(_videoListener!);

      await _videoPlayerController.initialize().timeout(
        const Duration(seconds: 18),
        onTimeout: () {
          throw TimeoutException('Video initialization timed out');
        },
      );

      if (_isDisposed) return;

      _chewieController?.removeListener(_chewieListener ?? () {});
      _chewieController?.dispose();
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
        errorBuilder:
            (context, errorMessage) => _buildErrorWidget(errorMessage),
        materialProgressColors: _getProgressColors(),
        additionalOptions: (context) => _buildAdditionalOptions(),
      );

      _chewieController?.removeListener(_chewieListener ?? () {});
      _chewieListener = () {
        if (!mounted) return;
        final isFs = _chewieController?.isFullScreen ?? false;
        if (isFs != _isFullScreen) setState(() => _isFullScreen = isFs);
      };
      _chewieController?.addListener(_chewieListener!);

      if (!_isDisposed) {
        setState(() {
          _isInitialized = true;
          _isError = false;
        });
      }
    } catch (e, st) {
      debugPrint('Video init failed: $e\n$st');
      if (!_isDisposed) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }

      if (_currentQuality != '360p' && _hasMultipleQualities()) {
        final fallback = _currentQuality == '1080p' ? '720p' : '360p';
        debugPrint('Attempting fallback quality: $fallback');
        _currentQuality = fallback;
        await Future.delayed(const Duration(milliseconds: 300));
        if (!_isDisposed) await _initializePlayer();
      }
    } finally {
      _isInitializing = false;
    }
  }

  List<OptionItem> _buildAdditionalOptions() {
    final options = <OptionItem>[];

    // Only show quality option if not fullscreen
    if (_hasMultipleQualities() && !_isFullScreen) {
      options.add(
        OptionItem(
          onTap: (context) => _showQualityDialog(context),
          iconData: Icons.hd,
          title: 'Quality ($_currentQuality)'.tr,
        ),
      );
    }
    return options;
  }

  bool _hasMultipleQualities() {
    // Auto and 360p are always available
    final urls = <String>{};
    urls.add(widget.url360p ?? widget.videoUrl); // 360p fallback to main url
    if (widget.url720p != null && widget.url720p!.isNotEmpty) {
      urls.add(widget.url720p!);
    }
    if (widget.url1080p != null && widget.url1080p!.isNotEmpty) {
      urls.add(widget.url1080p!);
    }
    // Only count distinct, non-empty URLs
    return urls.where((u) => u.isNotEmpty).length > 1;
  }

  Future<void> _showQualityDialog(BuildContext context) async {
    // Always show Auto and 360p, others only if present
    final qualityOptions = <String>['Auto', '360p'];
    if (widget.url720p != null && widget.url720p!.isNotEmpty) {
      qualityOptions.add('720p');
    }
    if (widget.url1080p != null && widget.url1080p!.isNotEmpty) {
      qualityOptions.add('1080p');
    }

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Select Quality'.tr,
              style: TextStyle(fontFamily: globalFontFamily),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  qualityOptions.map((quality) {
                    return ListTile(
                      title: Text(
                        quality.tr,
                        style: TextStyle(fontFamily: globalFontFamily),
                      ),
                      trailing:
                          _currentQuality == quality
                              ? const Icon(Icons.check)
                              : null,
                      onTap: () async {
                        Navigator.pop(context);
                        if (quality != _currentQuality) {
                          await _changeQuality(quality);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  String? _getQualityUrl(String quality) {
    // Auto and 360p always exist
    if (quality == 'Auto' || quality == '360p') {
      return widget.url360p != null && widget.url360p!.isNotEmpty
          ? widget.url360p
          : widget.videoUrl;
    }
    if (quality == '720p') {
      return widget.url720p != null && widget.url720p!.isNotEmpty
          ? widget.url720p
          : null;
    }
    if (quality == '1080p') {
      return widget.url1080p != null && widget.url1080p!.isNotEmpty
          ? widget.url1080p
          : null;
    }
    return widget.videoUrl;
  }

  Future<void> _changeQuality(String quality) async {
    if (_isDisposed) return;
    // Prevent quality change in fullscreen
    if (_isFullScreen) {
      Get.snackbar(
        'Quality Change Disabled',
        'Cannot change quality while fullscreen is open.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      setState(() {
        _isInitialized = false;
        _currentQuality = quality;
      });

      final wasPlaying = _videoPlayerController.value.isPlaying;
      final position = _videoPlayerController.value.position;

      final wasFullscreen = _isFullScreen;
      if (wasFullscreen) {
        try {
          _chewieController?.exitFullScreen();
        } catch (e) {
          debugPrint('Error exiting fullscreen before quality change: $e');
        }
        // give UI time to settle
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // tear down existing controllers
      try {
        await _videoPlayerController.pause();
      } catch (_) {}
      try {
        await _videoPlayerController.dispose();
      } catch (_) {}
      try {
        _chewieController?.removeListener(_chewieListener!);
      } catch (_) {}
      try {
        _chewieController?.dispose();
      } catch (_) {}

      await _initializePlayer();

      // restore fullscreen if it was fullscreen before
      if (wasFullscreen && !_isDisposed) {
        // allow Chewie to finish initialization
        await Future.delayed(const Duration(milliseconds: 250));
        try {
          _chewieController?.enterFullScreen();
        } catch (e) {
          debugPrint('Error re-entering fullscreen after quality change: $e');
        }
      }

      // restore playback position/state
      if (wasPlaying && !_isDisposed) {
        try {
          await _videoPlayerController.seekTo(position);
          await _videoPlayerController.play();
        } catch (e) {
          debugPrint('Error restoring playback after quality change: $e');
        }
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
      playedColor:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 210, 209, 224)
              : const Color.fromARGB(255, 40, 41, 61),
      bufferedColor:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 40, 41, 61)
              : const Color.fromARGB(255, 210, 209, 224),
      handleColor:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 40, 41, 61)
              : const Color.fromARGB(255, 210, 209, 224),
      backgroundColor:
          themeController.initialTheme == Themes.customLightTheme
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
            style: TextStyle(color: Colors.white, fontFamily: globalFontFamily),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializePlayer,
            child: Text(
              'Retry'.tr,
              style: TextStyle(fontFamily: globalFontFamily),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    try {
      if (_chewieListener != null) {
        _chewieController?.removeListener(_chewieListener!);
        _chewieListener = null;
      }
    } catch (_) {}

    try {
      _chewieController?.dispose();
    } catch (_) {}
    try {
      _videoPlayerController.dispose();
    } catch (_) {}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratingBreakdown = widget.videoData["rating_breakdown"] ?? {};
    final totalReviews =
        (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);
    final ThemeController themeController = Get.find<ThemeController>();
    Get.find<LocaleController>();

    final featuredRatings =
        widget.videoData["FeaturedRatings"] as List<dynamic>? ?? [];
    if (newFeaturedRating.isNotEmpty) {
      featuredRatings.addAll(newFeaturedRating);
    }
    newUserRating =
        widget.videoData['user_rating'] != null
            ? double.tryParse(widget.videoData['user_rating'].toString())
            : 0;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor:
            themeController.initialTheme == Themes.customLightTheme
                ? const Color.fromARGB(255, 210, 209, 224)
                : const Color.fromARGB(255, 40, 41, 61),
        body: SafeArea(
          child: ListView(
            children: [
              Center(
                child:
                    _isError
                        ? _buildErrorWidget(
                          _errorMessage ?? 'Failed to load video'.tr,
                        )
                        : _isInitialized && _chewieController != null
                        ? AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: RepaintBoundary(
                            child: Chewie(controller: _chewieController!),
                          ),
                        )
                        : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 20),
              _isInitialized && _chewieController != null
                  ? (widget.videoData.isEmpty)
                      ? noDataLottie("No data available")
                      : StatefulBuilder(
                        builder: (context, setDState) {
                          bool isRated =
                              ratedLessons[widget.videoData['id']] ?? false;
                          return Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // const SizedBox(width: 10),
                              Column(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_rounded,
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 40, 41, 61)
                                            : Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                    size: 30,
                                  ),
                                  Text(
                                    widget.videoData["views"].toString().tr,
                                    style: TextStyle(
                                      fontFamily: globalFontFamily,
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 12
                                              : 12 - (globalFontSizeChange / 5),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),

                              Column(
                                children: [
                                  LikeButton(
                                    size: 30,
                                    isLiked: IsLiked,
                                    likeBuilder: (bool isLiked) {
                                      return Icon(
                                        isLiked
                                            ? Icons.thumb_up_alt
                                            : Icons.thumb_up_alt_outlined,
                                        color:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  210,
                                                  209,
                                                  224,
                                                ),
                                        size: 30,
                                      );
                                    },
                                    onTap: (bool isLiked) async {
                                      // print(widget.videoData["id"].toString());

                                      await likesController.toggleLikes(
                                        widget.videoData["id"].toString(),
                                      );
                                      setState(() {
                                        widget.videoData["likes"] =
                                            likesController.likesCount;
                                        widget.videoData["dislikes"] =
                                            likesController.dislikesCount;

                                        widget.videoData["isLiked"] =
                                            likesController.isLiked;
                                        widget.videoData["isDisliked"] =
                                            likesController.isDisliked;
                                      });
                                      setDState(() {
                                        IsLiked = !isLiked;
                                        if (IsLiked) isDisLiked = false;
                                      });

                                      return !isLiked;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    widget.videoData["likes"].toString().tr,
                                    style: TextStyle(
                                      fontFamily: globalFontFamily,
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 12
                                              : 12 - (globalFontSizeChange / 5),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  LikeButton(
                                    size: 30,
                                    isLiked: isDisLiked,
                                    likeBuilder: (bool isLiked) {
                                      return Icon(
                                        isLiked
                                            ? Icons.thumb_down_alt
                                            : Icons.thumb_down_alt_outlined,
                                        color:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  210,
                                                  209,
                                                  224,
                                                ),
                                        size: 30,
                                      );
                                    },
                                    onTap: (bool isLiked) async {
                                      // print(widget.videoData["id"].toString());
                                      await likesController.toggleDisLikes(
                                        widget.videoData["id"].toString(),
                                      );
                                      setState(() {
                                        widget.videoData["likes"] =
                                            likesController.likesCount;
                                        widget.videoData["dislikes"] =
                                            likesController.dislikesCount;

                                        widget.videoData["isLiked"] =
                                            likesController.isLiked;
                                        widget.videoData["isDisliked"] =
                                            likesController.isDisliked;
                                      });

                                      setDState(() {
                                        isDisLiked = !isLiked;
                                        if (isDisLiked) IsLiked = false;
                                      });
                                      return !isLiked;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    widget.videoData["dislikes"].toString().tr,
                                    style: TextStyle(
                                      fontFamily: globalFontFamily,
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 12
                                              : 12 - (globalFontSizeChange / 5),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      showRatingDailog(
                                        context,
                                        widget.videoData["id"],
                                        token,
                                        "$mainIP/api/ratelecture/${widget.videoData["id"]}",

                                        () async {
                                          setState(() {
                                            newUserRating = userRating;
                                            newFeaturedRating =
                                                List<Map<String, dynamic>>.from(
                                                  newRatingData,
                                                );
                                            newBreakingDown =
                                                Map<String, dynamic>.from(
                                                  newRatingsBreakingDown,
                                                );
                                            newCTRLRating = newRating;

                                            if (newFeaturedRating.isNotEmpty) {
                                              if (isCreated == false &&
                                                  featuredRatings.isNotEmpty) {
                                                featuredRatings.removeAt(0);
                                              }
                                              featuredRatings.insert(
                                                0,
                                                newFeaturedRating.first,
                                              );
                                            }

                                            if (newFeaturedRating.isEmpty) {
                                              if (isCreated == false &&
                                                  featuredRatings.isNotEmpty) {
                                                featuredRatings.removeAt(0);
                                              }
                                            }
                                            widget.videoData['featuredRatings'] =
                                                featuredRatings;
                                            widget.videoData['rating_breakdown'] =
                                                newBreakingDown;
                                            widget.videoData['user_rating'] =
                                                newUserRating;
                                            widget.videoData['rating'] =
                                                newCTRLRating;

                                            ratedLessons[widget
                                                    .videoData["id"]] =
                                                true;
                                          });
                                          await sharedPrefs.saveMap(
                                            "ratedLessons",
                                            ratedLessons,
                                          );
                                        },
                                        newUserRating ?? 0,
                                      );
                                      print("${widget.videoData["id"]}");
                                    },
                                    icon: Icon(
                                      (isRated)
                                          ? Icons.star_outlined
                                          : Icons.star_border_outlined,
                                    ),
                                    color: Colors.blue,
                                    iconSize: 25,
                                  ),
                                  Text(
                                    (isRated)
                                        ? newUserRating.toString().tr
                                        : "Rate This".tr,
                                    style: TextStyle(
                                      fontFamily: globalFontFamily,
                                      color: Colors.blue,
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 12
                                              : 12 - (globalFontSizeChange / 5),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(width: 10),
                            ],
                          );
                        },
                      )
                  : const SizedBox(),

              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Description".tr,
                      style: TextStyle(
                        fontFamily: globalFontFamily,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                        fontSize:
                            globalFontSizeChange <= 17
                                ? (globalFontSizeChange / 5) + 20
                                : 20 - (globalFontSizeChange / 5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "${widget.videoData["description"]}".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: globalFontFamily,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                        fontSize:
                            globalFontSizeChange <= 17
                                ? (globalFontSizeChange / 5) + 16
                                : 16 - (globalFontSizeChange / 5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      children: [
                        Text(
                          "Course Name:".tr,
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 18
                                    : 18 - (globalFontSizeChange / 5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),

                        Text(
                          "${widget.videoData["courseName"]}".tr,
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 16
                                    : 16 - (globalFontSizeChange / 5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      children: [
                        Text(
                          "Teacher Name:".tr,
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 18
                                    : 18 - (globalFontSizeChange / 5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),

                        Text(
                          "${widget.videoData["teacherName"]}".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 16
                                    : 16 - (globalFontSizeChange / 5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_outlined,
                                    color: Colors.amber,
                                    size: 25,
                                  ),
                                  Text(
                                    "${(widget.videoData['rating'] == null)
                                        ? "0"
                                        : (newCTRLRating == null)
                                        ? widget.videoData['rating'].toString()
                                        : newCTRLRating.toString()}/5",
                                    style: TextStyle(
                                      fontFamily: globalFontFamily,
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 22
                                              : 22 - (globalFontSizeChange / 5),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),

                              Text(
                                "based on (${totalReviews.toString()}) reviews",
                                style: TextStyle(
                                  fontFamily: globalFontFamily,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  fontSize:
                                      globalFontSizeChange <= 17
                                          ? (globalFontSizeChange / 5) + 20
                                          : 20 - (globalFontSizeChange / 5),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Column(
                      children: [
                        buildRatingBar(
                          5,
                          _areBarsVisible,
                          widget.videoData["rating_breakdown"],
                        ),
                        const SizedBox(height: 6),
                        buildRatingBar(
                          4,
                          _areBarsVisible,
                          widget.videoData["rating_breakdown"],
                        ),
                        const SizedBox(height: 6),
                        buildRatingBar(
                          3,
                          _areBarsVisible,
                          widget.videoData["rating_breakdown"],
                        ),
                        const SizedBox(height: 6),
                        buildRatingBar(
                          2,
                          _areBarsVisible,
                          widget.videoData["rating_breakdown"],
                        ),
                        const SizedBox(height: 6),
                        buildRatingBar(
                          1,
                          _areBarsVisible,
                          widget.videoData["rating_breakdown"],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      height: 1,
                      width: Get.width / 1.1,
                      decoration: BoxDecoration(
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(60)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: Get.width / 3.5,
                        height: 40,
                        child: MaterialButton(
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                          textColor:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 210, 209, 224)
                                  : Color.fromARGB(255, 40, 41, 61),

                          onPressed: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ReviewsPage(
                                      type: "getlectureratings",
                                      sectionId: widget.videoData["id"],
                                    ),
                              ),
                            );
                            _areBarsVisible = false;
                            Animations();
                          },
                          child: Text(
                            "See All Reviews".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: globalFontFamily,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 14
                                      : 14 - (globalFontSizeChange / 5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      width: Get.width,
                      decoration: BoxDecoration(
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(60)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Reviews List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          (featuredRatings.length < 4)
                              ? featuredRatings.length
                              : 3,
                      itemBuilder: (context, index) {
                        featuredRatings.length;

                        final review =
                            featuredRatings[index] as Map<String, dynamic>? ??
                            {};

                        print("ffff $review");
                        final reviewId = review['id'] ?? index;

                        helpfulStates[reviewId] ??= review["isHelpful"] == true;
                        unhelpfulStates[reviewId] ??=
                            review["isUnhelpful"] == true;
                        // IsHelpful =
                        //     widget
                        //         .videoData["FeaturedRatings"][index]["isHelpful"] ==
                        //     true;
                        // IsUnHelpful =
                        //     widget
                        //         .videoData["FeaturedRatings"][index]["isUnhelpful"] ==
                        //     true;
                        final reviewText =
                            review["review"]?.toString().tr ?? 'No review'.tr;
                        final textSpan = TextSpan(
                          text: reviewText,
                          style: TextStyle(
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 12
                                    : 12 - (globalFontSizeChange / 5),
                            fontWeight: FontWeight.w200,
                          ),
                        );
                        final textPainter = TextPainter(
                          text: textSpan,
                          maxLines: 3,
                          textDirection: TextDirection.ltr,
                        );
                        textPainter.layout(maxWidth: Get.width / 1.1);
                        final isLong = textPainter.didExceedMaxLines;
                        final isExpanded = expandedReviews.contains(index);

                        return SizedBox(
                          width: Get.width / 1.1,
                          child: StatefulBuilder(
                            builder: (context, setDiaState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review["user_name"]
                                                      ?.toString()
                                                      .tr ??
                                                  ''.tr,
                                              style: TextStyle(
                                                fontFamily: globalFontFamily,
                                                color:
                                                    (review["user_name"] ==
                                                            profileController
                                                                .profileData['userName'])
                                                        ? themeController
                                                                    .initialTheme ==
                                                                Themes
                                                                    .customLightTheme
                                                            ? Colors
                                                                .orangeAccent
                                                                .shade400
                                                            : Colors.amber
                                                        : themeController
                                                                .initialTheme ==
                                                            Themes
                                                                .customLightTheme
                                                        ? Color.fromARGB(
                                                          255,
                                                          40,
                                                          41,
                                                          61,
                                                        )
                                                        : Color.fromARGB(
                                                          255,
                                                          210,
                                                          209,
                                                          224,
                                                        ),
                                                fontSize:
                                                    globalFontSizeChange <= 17
                                                        ? (globalFontSizeChange /
                                                                5) +
                                                            16
                                                        : 16 -
                                                            (globalFontSizeChange /
                                                                5),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star_outlined,
                                                  color: Colors.amber,
                                                  size: 20,
                                                ),
                                                Text(
                                                  "${review["rating"]?.toString()}"
                                                      .tr,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        globalFontFamily,
                                                    color:
                                                        themeController
                                                                    .initialTheme ==
                                                                Themes
                                                                    .customLightTheme
                                                            ? Color.fromARGB(
                                                              255,
                                                              40,
                                                              41,
                                                              61,
                                                            )
                                                            : Color.fromARGB(
                                                              255,
                                                              210,
                                                              209,
                                                              224,
                                                            ),
                                                    fontSize:
                                                        globalFontSizeChange <=
                                                                17
                                                            ? (globalFontSizeChange /
                                                                    5) +
                                                                14
                                                            : 14 -
                                                                (globalFontSizeChange /
                                                                    5),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          review["updated_at"]?.toString().tr ??
                                              ''.tr,
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            color:
                                                themeController.initialTheme ==
                                                        Themes.customLightTheme
                                                    ? Color.fromARGB(
                                                      255,
                                                      40,
                                                      41,
                                                      61,
                                                    )
                                                    : Color.fromARGB(
                                                      255,
                                                      210,
                                                      209,
                                                      224,
                                                    ),
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        10
                                                    : 10 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.w200,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        color:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  210,
                                                  209,
                                                  224,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                ),
                                        icon: Icon(Icons.more_vert_rounded),
                                        iconSize: 20,
                                        iconColor:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  210,
                                                  209,
                                                  224,
                                                ),
                                        onSelected: (value) async {
                                          if (value == 'report') {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                bool localReport1 = report1;
                                                bool localReport2 = report2;
                                                bool localReport3 = report3;
                                                return StatefulBuilder(
                                                  builder:
                                                      (
                                                        context,
                                                        setDialogState,
                                                      ) => AlertDialog(
                                                        title: Text(
                                                          "Reasons:".tr,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                globalFontFamily,
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  40,
                                                                  41,
                                                                  61,
                                                                ),
                                                            fontSize:
                                                                globalFontSizeChange >=
                                                                        17
                                                                    ? (globalFontSizeChange /
                                                                            5) +
                                                                        18
                                                                    : 18 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            CheckboxListTile(
                                                              title: Text(
                                                                "Offensive:".tr,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      globalFontFamily,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      ),
                                                                  fontSize:
                                                                      globalFontSizeChange >=
                                                                              17
                                                                          ? (globalFontSizeChange /
                                                                                  5) +
                                                                              14
                                                                          : 14 -
                                                                              (globalFontSizeChange /
                                                                                  5),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              value:
                                                                  localReport1,
                                                              onChanged: (
                                                                value,
                                                              ) {
                                                                setDialogState(
                                                                  () {
                                                                    localReport1 =
                                                                        value ??
                                                                        false;
                                                                  },
                                                                );
                                                                setDiaState(() {
                                                                  report1 =
                                                                      value ??
                                                                      false;
                                                                });
                                                              },
                                                            ),
                                                            CheckboxListTile(
                                                              title: Text(
                                                                "Inappropriate:"
                                                                    .tr,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      globalFontFamily,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      ),
                                                                  fontSize:
                                                                      globalFontSizeChange >=
                                                                              17
                                                                          ? (globalFontSizeChange /
                                                                                  5) +
                                                                              14
                                                                          : 14 -
                                                                              (globalFontSizeChange /
                                                                                  5),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              value:
                                                                  localReport2,
                                                              onChanged: (
                                                                value,
                                                              ) {
                                                                setDialogState(
                                                                  () {
                                                                    localReport2 =
                                                                        value ??
                                                                        false;
                                                                  },
                                                                );
                                                                setDiaState(() {
                                                                  report2 =
                                                                      value ??
                                                                      false;
                                                                });
                                                              },
                                                            ),
                                                            CheckboxListTile(
                                                              title: Text(
                                                                "Unrelated:".tr,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      globalFontFamily,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      ),
                                                                  fontSize:
                                                                      globalFontSizeChange >=
                                                                              17
                                                                          ? (globalFontSizeChange /
                                                                                  5) +
                                                                              14
                                                                          : 14 -
                                                                              (globalFontSizeChange /
                                                                                  5),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              value:
                                                                  localReport3,
                                                              onChanged: (
                                                                value,
                                                              ) {
                                                                setDialogState(
                                                                  () {
                                                                    localReport3 =
                                                                        value ??
                                                                        false;
                                                                  },
                                                                );
                                                                setDiaState(() {
                                                                  report3 =
                                                                      value ??
                                                                      false;
                                                                });
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Container(
                                                              height: 80,
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    right: 30,
                                                                    left: 30,
                                                                  ),
                                                              child: TextFormField(
                                                                style: TextStyle(
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      ),
                                                                ),
                                                                controller:
                                                                    reportController,
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .onUserInteraction,
                                                                cursorColor:
                                                                    const Color.fromARGB(
                                                                      255,
                                                                      254,
                                                                      233,
                                                                      204,
                                                                    ),
                                                                obscureText:
                                                                    false,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .text,

                                                                decoration: InputDecoration(
                                                                  prefixIcon:
                                                                      const Icon(
                                                                        Icons
                                                                            .message_rounded,
                                                                        size:
                                                                            25,
                                                                      ),
                                                                  prefixIconColor:
                                                                      const Color.fromARGB(
                                                                        255,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      ),
                                                                  hintText:
                                                                      "Message (optional)"
                                                                          .tr,
                                                                  hintStyle: TextStyle(
                                                                    color:
                                                                        const Color.fromARGB(
                                                                          255,
                                                                          40,
                                                                          41,
                                                                          61,
                                                                        ),
                                                                  ),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          6,
                                                                        ),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                          width:
                                                                              2,
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            40,
                                                                            41,
                                                                            61,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          6,
                                                                        ),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            40,
                                                                            41,
                                                                            61,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                  errorBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          6,
                                                                        ),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            23,
                                                                            7,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                  focusedErrorBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          6,
                                                                        ),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                          width:
                                                                              2,
                                                                          color: Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            23,
                                                                            7,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                ),

                                                                // validator: (
                                                                //   val,
                                                                // ) {
                                                                //   if (val!.isEmpty) {
                                                                //     return "Please enter A User Name".tr;
                                                                //   } else {
                                                                //     if (val.length <
                                                                //         3) {
                                                                //       return "User Name must be longer than 3 characters".tr;
                                                                //     } else if (val.length >
                                                                //         25) {
                                                                //       return "User Name must be shorter than 25 characters".tr;
                                                                //     }
                                                                //   }
                                                                //   return null;
                                                                // },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),

                                                            MaterialButton(
                                                              onPressed: () async {
                                                                if (localReport1 ==
                                                                    true) {
                                                                  ReportList.add(
                                                                    'offensive',
                                                                  );
                                                                }
                                                                if (localReport2 ==
                                                                    true) {
                                                                  ReportList.add(
                                                                    'inappropriate',
                                                                  );
                                                                }
                                                                if (localReport3 ==
                                                                    true) {
                                                                  ReportList.add(
                                                                    'unrelated',
                                                                  );
                                                                }
                                                                // await networkController.checkConnectivityManually();
                                                                isConnected =
                                                                    sharedPrefs
                                                                        .prefs
                                                                        .getBool(
                                                                          'isConnected',
                                                                        );
                                                                if (isConnected ==
                                                                    true) {
                                                                  if (ReportList
                                                                      .isNotEmpty) {
                                                                    likesController.reportReview(
                                                                      'lecture_rating_id',
                                                                      reviewId
                                                                          .toString(),
                                                                      ReportList,
                                                                      reportController
                                                                          .text
                                                                          .toString(),
                                                                    );
                                                                    ReportList.clear();
                                                                  } else {
                                                                    Get.rawSnackbar(
                                                                      title:
                                                                          "Warning"
                                                                              .tr,
                                                                      messageText: Text(
                                                                        "You need to choose at least one reason"
                                                                            .tr,
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              globalFontFamily,
                                                                        ),
                                                                      ),
                                                                      isDismissible:
                                                                          true,
                                                                      snackPosition:
                                                                          SnackPosition
                                                                              .BOTTOM,
                                                                      duration: const Duration(
                                                                        seconds:
                                                                            3,
                                                                      ),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      icon: const Icon(
                                                                        Icons
                                                                            .priority_high_outlined,
                                                                        color:
                                                                            Colors.white,
                                                                        size:
                                                                            35,
                                                                      ),
                                                                      margin:
                                                                          const EdgeInsets.all(
                                                                            5,
                                                                          ),
                                                                      borderRadius:
                                                                          5,
                                                                      borderColor:
                                                                          Colors
                                                                              .grey[700]!,
                                                                    );
                                                                  }
                                                                } else {
                                                                  Get.snackbar(
                                                                    "Connection error"
                                                                        .tr,
                                                                    "Connection access is needed"
                                                                        .tr,
                                                                  );
                                                                }
                                                              },
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    210,
                                                                    209,
                                                                    224,
                                                                  ),
                                                              minWidth:
                                                                  Get.width /
                                                                  3.5,
                                                              height: 35,
                                                              child: Text(
                                                                "Submit".tr,
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      globalFontSizeChange >=
                                                                              17
                                                                          ? (globalFontSizeChange /
                                                                                  5) +
                                                                              20
                                                                          : 20 -
                                                                              (globalFontSizeChange /
                                                                                  5),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .normal,
                                                                  color:
                                                                      const Color.fromARGB(
                                                                        255,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                onTap: () {
                                                  report1 = false;
                                                  report2 = false;
                                                  report3 = false;
                                                },
                                                value: 'report',
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "report".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        color:
                                                            themeController
                                                                        .initialTheme ==
                                                                    Themes
                                                                        .customLightTheme
                                                                ? Color.fromARGB(
                                                                  255,
                                                                  40,
                                                                  41,
                                                                  61,
                                                                )
                                                                : Color.fromARGB(
                                                                  255,
                                                                  210,
                                                                  209,
                                                                  224,
                                                                ),
                                                        fontSize:
                                                            globalFontSizeChange <=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    14
                                                                : 14 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reviewText,
                                        maxLines: isExpanded ? null : 3,
                                        overflow:
                                            isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: globalFontFamily,
                                          color:
                                              themeController.initialTheme ==
                                                      Themes.customLightTheme
                                                  ? Color.fromARGB(
                                                    255,
                                                    40,
                                                    41,
                                                    61,
                                                  )
                                                  : Color.fromARGB(
                                                    255,
                                                    210,
                                                    209,
                                                    224,
                                                  ),
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      12
                                                  : 12 -
                                                      (globalFontSizeChange /
                                                          5),
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                      if (isLong && !isExpanded)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              expandedReviews.add(index);
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            'Read more...',
                                            style: TextStyle(
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
                                                      ? Color.fromARGB(
                                                        255,
                                                        46,
                                                        48,
                                                        97,
                                                      )
                                                      : Color.fromARGB(
                                                        255,
                                                        153,
                                                        151,
                                                        188,
                                                      ),
                                              fontFamily: globalFontFamily,
                                            ),
                                          ),
                                        ),
                                      if (isExpanded && isLong)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              expandedReviews.remove(index);
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            'Show less',
                                            style: TextStyle(
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
                                                      ? Color.fromARGB(
                                                        255,
                                                        46,
                                                        48,
                                                        97,
                                                      )
                                                      : Color.fromARGB(
                                                        255,
                                                        153,
                                                        151,
                                                        188,
                                                      ),
                                              fontFamily: globalFontFamily,
                                            ),
                                          ),
                                        ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          LikeButton(
                                            size: 20,
                                            isLiked:
                                                helpfulStates[reviewId] ??
                                                false,
                                            likeBuilder: (bool isLiked) {
                                              return Icon(
                                                isLiked
                                                    ? Icons.thumb_up_alt
                                                    : Icons
                                                        .thumb_up_alt_outlined,
                                                color:
                                                    themeController
                                                                .initialTheme ==
                                                            Themes
                                                                .customLightTheme
                                                        ? Color.fromARGB(
                                                          255,
                                                          40,
                                                          41,
                                                          61,
                                                        )
                                                        : Color.fromARGB(
                                                          255,
                                                          210,
                                                          209,
                                                          224,
                                                        ),
                                                size: 20,
                                              );
                                            },
                                            onTap: (bool isLiked) async {
                                              // print(widget.videoData["id"].toString());

                                              await likesController.toggleHelpful({
                                                "lecture_rating_id":
                                                    featuredRatings[index]['id'],
                                              });
                                              review["isHelpful"] =
                                                  likesController.isHelpful;
                                              review["isUnhelpful"] =
                                                  likesController.isUnhelpful;

                                              setDiaState(() {
                                                helpfulStates[reviewId] =
                                                    !isLiked;
                                                if (helpfulStates[reviewId] ==
                                                    true) {
                                                  unhelpfulStates[reviewId] =
                                                      false;
                                                }
                                              });

                                              return !isLiked;
                                            },
                                          ),
                                          const SizedBox(width: 10),

                                          LikeButton(
                                            size: 20,
                                            isLiked:
                                                unhelpfulStates[reviewId] ??
                                                false,
                                            likeBuilder: (bool isLiked) {
                                              return Icon(
                                                isLiked
                                                    ? Icons.thumb_down_alt
                                                    : Icons
                                                        .thumb_down_alt_outlined,
                                                color:
                                                    themeController
                                                                .initialTheme ==
                                                            Themes
                                                                .customLightTheme
                                                        ? Color.fromARGB(
                                                          255,
                                                          40,
                                                          41,
                                                          61,
                                                        )
                                                        : Color.fromARGB(
                                                          255,
                                                          210,
                                                          209,
                                                          224,
                                                        ),
                                                size: 20,
                                              );
                                            },
                                            onTap: (bool isLiked) async {
                                              // print(widget.videoData["id"].toString());
                                              await likesController
                                                  .toggleUnhelpful({
                                                    "lecture_rating_id":
                                                        featuredRatings[index]['id'],
                                                  });
                                              review["isHelpful"] =
                                                  likesController.isHelpful;
                                              review["isUnhelpful"] =
                                                  likesController.isUnhelpful;
                                              setDiaState(() {
                                                unhelpfulStates[reviewId] =
                                                    !isLiked;
                                                if (unhelpfulStates[reviewId] ==
                                                    true) {
                                                  helpfulStates[reviewId] =
                                                      false;
                                                }
                                              });
                                              return !isLiked;
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 1,
                                    width: Get.width / 1.1,
                                    decoration: BoxDecoration(
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(60),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
