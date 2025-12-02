// ignore_for_file: file_names

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/NetworkController.dart';
import '../../themes/Themes.dart';
import '../../themes/ThemeController.dart';
import '../../view/NavBar.dart';
import '../constants/FontGlobals.dart';
import '../constants/ImageAssets.dart';

class AudioBook extends StatefulWidget {
  final Map<String, dynamic> audioBookData;
  // final Uint8List? audioBookImage;

  const AudioBook({
    super.key,
    required this.audioBookData,
    // required this.audioBookImage,
  });

  @override
  State<AudioBook> createState() => _AudioBookState();
}

class _AudioBookState extends State<AudioBook> {
  final NetworkController networkController = Get.find<NetworkController>();
  final ThemeController themeController = Get.find<ThemeController>();

  String? _currentSourceUrl;

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _currentVolume = 1.0;
  double _playbackSpeed = 1.0;
  Color? _dominantColor;
  late String _bookId;
  SharedPreferences? _prefs;
  bool _prefsInitialized = false;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<void>? _completeSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  Timer? _skipTimer;
  bool _isLongPressing = false;

  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 4.0];

  @override
  void initState() {
    super.initState();
    _initializeAudioBook();
  }

  Future<void> _initializeAudioBook() async {
    try {
      _bookId = widget.audioBookData['id']?.toString() ?? 'unknown';
      if (widget.audioBookData['audio_file_duration_seconds'] != null) {
        _totalDuration = Duration(
          seconds:
              (widget.audioBookData['audio_file_duration_seconds'] as num)
                  .toInt(),
        );
      }
      if (widget.audioBookData['image'] != null) {
        _extractDominantColor();
      }
      await _initializeSharedPreferences();
      await _initializeAudioPlayer();
      _setupAudioPlayerListeners();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing AudioBook: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _initializeSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _prefsInitialized = true;
      final savedPosition = await _loadAudioPosition();
      if (mounted) {
        setState(() => _currentPosition = savedPosition);
      }
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer = AudioPlayer();
  }

  void _setupAudioPlayerListeners() {
    if (_audioPlayer == null) return;

    _positionSubscription = _audioPlayer!.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
        _saveAudioPosition();
      }
    });

    _durationSubscription = _audioPlayer!.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _totalDuration = duration);
      }
    });

    _completeSubscription = _audioPlayer!.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        _saveAudioPosition();
      }
    });

    _stateSubscription = _audioPlayer!.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  Future<void> _playOrPauseAudio() async {
    if (!mounted) return;

    final audioUrl = widget.audioBookData['audio_file_url']?.toString() ?? '';
    if (audioUrl.isEmpty) {
      _showSnackBar("Audio URL is missing or invalid.");
      return;
    }

    _audioPlayer ??= AudioPlayer();

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
        await _saveAudioPosition();
        if (mounted) setState(() => _isPlaying = false);
        return;
      }

      final savedPosition = await _loadAudioPosition();

      if (_currentSourceUrl != null && _currentSourceUrl == audioUrl) {
        final diff = (savedPosition - _currentPosition).inMilliseconds.abs();
        if (diff > 700) {
          await _audioPlayer!.seek(savedPosition);
          await Future.delayed(const Duration(milliseconds: 120));
        }
        await _audioPlayer!.resume();
        if (mounted) setState(() => _isPlaying = true);
        return;
      }

      try {
        await _audioPlayer!.stop();
      } catch (_) {}

      try {
        await _audioPlayer!.setSourceUrl(audioUrl);
        _currentSourceUrl = audioUrl;
      } catch (e) {
        debugPrint('Failed to set audio source: $e');
        _showSnackBar("Failed to load audio.");
        return;
      }

      if (savedPosition > Duration.zero) {
        await _audioPlayer!.seek(savedPosition);
        await Future.delayed(const Duration(milliseconds: 150));
      }

      await _audioPlayer!.resume();
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint("Audio play error: $e");
      _showSnackBar("Playback error.");
    }
  }

  Future<void> _seekToPosition(Duration position) async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.seek(position);
      setState(() => _currentPosition = position);
      await _saveAudioPosition();
    } catch (e) {
      debugPrint('Seek error: $e');
    }
  }

  Future<void> _skipForward() async {
    final newPosition = Duration(
      seconds: (_currentPosition.inSeconds + 10).clamp(
        0,
        _totalDuration.inSeconds,
      ),
    );
    await _seekToPosition(newPosition);
  }

  Future<void> _skipBackward() async {
    final newPosition = Duration(
      seconds: (_currentPosition.inSeconds - 10).clamp(
        0,
        _totalDuration.inSeconds,
      ),
    );
    await _seekToPosition(newPosition);
  }

  void _startLongPressSkip(bool isForward) {
    if (_isLongPressing) return;
    _isLongPressing = true;
    _skipTimer = Timer.periodic(Duration(milliseconds: 400), (_) {
      if (!_isLongPressing) return;
      isForward ? _skipForward() : _skipBackward();
    });
  }

  void _stopLongPressSkip() {
    _isLongPressing = false;
    _skipTimer?.cancel();
    _skipTimer = null;
  }

  Future<void> _changeVolume(double volume) async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.setVolume(volume);
      setState(() => _currentVolume = volume);
    } catch (e) {
      debugPrint('Volume error: $e');
    }
  }

  Future<void> _changePlaybackSpeed(double speed) async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.setPlaybackRate(speed);
      setState(() => _playbackSpeed = speed);
    } catch (e) {
      debugPrint('Speed change error: $e');
    }
  }

  Future<void> _extractDominantColor() async {
    try {
      // Support multiple shapes for image data: String (URL/path), Uint8List, List<int>
      final dynamic rawImage = widget.audioBookData['image'];
      if (rawImage == null) return;

      Uint8List? imageBytes;

      if (rawImage is String) {
        // Build full URL if it's a relative path
        final url =
            rawImage.startsWith('http') ? rawImage : '$mainIP/$rawImage';
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) {
          imageBytes = resp.bodyBytes;
        } else {
          debugPrint(
            'Failed to download image for color extraction: ${resp.statusCode}',
          );
          return;
        }
      } else if (rawImage is Uint8List) {
        imageBytes = rawImage;
      } else if (rawImage is List<int>) {
        imageBytes = Uint8List.fromList(rawImage);
      } else {
        debugPrint(
          'Unsupported image type for color extraction: ${rawImage.runtimeType}',
        );
        return;
      }

      if (imageBytes.isEmpty) return;

      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      int r = 0, g = 0, b = 0, count = 0;
      // sample pixels with a step to avoid expensive loops on large images
      final step = 40; // keep previous behavior sampling every 40 bytes
      for (int i = 0; i < bytes.length; i += step) {
        if (i + 2 < bytes.length) {
          r += bytes[i];
          g += bytes[i + 1];
          b += bytes[i + 2];
          count++;
        }
      }

      if (count > 0) {
        setState(() {
          _dominantColor = Color.fromARGB(
            255,
            (r ~/ count),
            (g ~/ count),
            (b ~/ count),
          );
        });
      }
    } catch (e) {
      debugPrint('Color extraction error: $e');
    }
  }

  Future<void> _saveAudioPosition() async {
    if (!_prefsInitialized || _prefs == null) return;
    try {
      await _prefs!.setInt(
        'audio_position_$_bookId',
        _currentPosition.inSeconds,
      );
    } catch (e) {
      debugPrint('Position save error: $e');
    }
  }

  Future<Duration> _loadAudioPosition() async {
    if (!_prefsInitialized || _prefs == null) return Duration.zero;
    try {
      final seconds = _prefs!.getInt('audio_position_$_bookId') ?? 0;
      return Duration(seconds: seconds);
    } catch (e) {
      debugPrint('Position load error: $e');
      return Duration.zero;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(fontFamily: globalFontFamily),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completeSubscription?.cancel();
    _stateSubscription?.cancel();
    _stopLongPressSkip();
    _saveAudioPosition();
    try {
      _audioPlayer?.stop();
    } catch (_) {}
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        themeController.initialTheme == Themes.customLightTheme
            ? Color.fromARGB(255, 40, 41, 61)
            : Color.fromARGB(255, 210, 209, 224);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: _dominantColor,
        // themeController.initialTheme == Themes.customLightTheme
        //     ? Color.fromARGB(255, 210, 209, 224)
        //     : Color.fromARGB(255, 46, 48, 97),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : widget.audioBookData.isEmpty
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_outlined,
                            size: 35,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _dominantColor,
                          // ?? accentColor.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              widget.audioBookData['image'] != null
                                  ? CachedNetworkImage(
                                    imageUrl:
                                        "$mainIP/${widget.audioBookData['image']}",
                                    height: 60,
                                    width: 60,
                                  )
                                  : Image.asset(
                                    ImageAssets.book,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "${widget.audioBookData["name"]}".tr,
                        style: TextStyle(
                          fontFamily: globalFontFamily,
                          fontSize:
                              globalFontSizeChange <= 17
                                  ? (globalFontSizeChange / 5) + 22
                                  : 22 - (globalFontSizeChange / 5),
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Author: ${widget.audioBookData["author"]}".tr,
                      style: TextStyle(
                        fontSize:
                            globalFontSizeChange <= 17
                                ? (globalFontSizeChange / 5) + 16
                                : 16 - (globalFontSizeChange / 5),
                        fontFamily: globalFontFamily,
                        fontWeight: FontWeight.w400,
                        color: accentColor.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Publish Date: ${widget.audioBookData["publish date"]}"
                          .tr,
                      style: TextStyle(
                        fontSize:
                            globalFontSizeChange <= 17
                                ? (globalFontSizeChange / 5) + 14
                                : 14 - (globalFontSizeChange / 5),
                        fontWeight: FontWeight.w300,
                        fontFamily: globalFontFamily,
                        color: accentColor.withValues(alpha: .6),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: accentColor,
                          inactiveTrackColor: accentColor.withValues(
                            alpha: 0.3,
                          ),
                          thumbColor: accentColor,
                          overlayColor: accentColor.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _currentPosition.inSeconds.toDouble(),
                          min: 0,
                          // max: widget.audioBookData["audio_file_duration_seconds"].toDouble() > 0
                          //     ? widget.audioBookData["audio_file_duration_seconds"].toDouble()
                          //     : 1,
                          max:
                              _totalDuration.inSeconds > 0
                                  ? _totalDuration.inSeconds.toDouble()
                                  : 1,
                          onChanged: (value) {
                            final position = Duration(seconds: value.toInt());
                            _seekToPosition(position);
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: TextStyle(
                              color: accentColor,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 14
                                      : 14 - (globalFontSizeChange / 5),
                              fontFamily: globalFontFamily,
                            ),
                          ),
                          Text(
                            _formatDuration(_totalDuration),
                            style: TextStyle(
                              color: accentColor,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 14
                                      : 14 - (globalFontSizeChange / 5),
                              fontFamily: globalFontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTapDown: (_) => _startLongPressSkip(false),
                          onTapUp: (_) => _stopLongPressSkip(),
                          onTapCancel: () => _stopLongPressSkip(),
                          child: IconButton(
                            icon: Icon(Icons.replay_10),
                            iconSize: 32,
                            color: accentColor,
                            onPressed: _skipBackward,
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            iconSize: 40,
                            onPressed: _playOrPauseAudio,
                          ),
                        ),

                        GestureDetector(
                          onTapDown: (_) => _startLongPressSkip(true),
                          onTapUp: (_) => _stopLongPressSkip(),
                          onTapCancel: () => _stopLongPressSkip(),
                          child: IconButton(
                            icon: Icon(Icons.forward_10),
                            iconSize: 32,
                            color: accentColor,
                            onPressed: _skipForward,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      child: Row(
                        children: [
                          Icon(Icons.volume_down, color: accentColor, size: 20),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: accentColor,
                                inactiveTrackColor: accentColor.withValues(
                                  alpha: 0.3,
                                ),
                                thumbColor: accentColor,
                                overlayColor: accentColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              child: Slider(
                                value: _currentVolume,
                                min: 0,
                                max: 1,
                                onChanged: _changeVolume,
                              ),
                            ),
                          ),
                          Icon(Icons.volume_up, color: accentColor, size: 20),
                          const SizedBox(width: 40),
                          Text(
                            "Speed: ",
                            style: TextStyle(
                              color: accentColor,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 14
                                      : 14 - (globalFontSizeChange / 5),
                              fontFamily: globalFontFamily,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<double>(
                              dropdownColor: Color.fromARGB(255, 40, 41, 61),
                              value: _playbackSpeed,
                              underline: const SizedBox(),
                              style: TextStyle(
                                color: accentColor,
                                fontSize:
                                    globalFontSizeChange <= 17
                                        ? (globalFontSizeChange / 5) + 14
                                        : 14 - (globalFontSizeChange / 5),
                              ),
                              items:
                                  _speedOptions.map((speed) {
                                    return DropdownMenuItem<double>(
                                      value: speed,
                                      child: Text(
                                        ' ${speed}x',
                                        style: TextStyle(
                                          fontFamily: globalFontFamily,
                                          color: accentColor.withValues(
                                            alpha: 1,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _changePlaybackSpeed(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
      ),
    );
  }
}
