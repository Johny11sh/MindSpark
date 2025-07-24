// ignore_for_file: file_names

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/NetworkController.dart';
import '../../themes/Themes.dart';
import '../../themes/ThemeController.dart';
import '../constants/ImageAssets.dart';

class AudioBook extends StatefulWidget {
  final Map<String, dynamic> audioBookData;
  final Uint8List? audioBookImage;

  const AudioBook({
    super.key,
    required this.audioBookData,
    required this.audioBookImage,
  });

  @override
  State<AudioBook> createState() => _AudioBookState();
}

class _AudioBookState extends State<AudioBook> {
  final NetworkController networkController = Get.find<NetworkController>();
  final ThemeController themeController = Get.find<ThemeController>();

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
          seconds: (widget.audioBookData['audio_file_duration_seconds'] as num).toInt(),
        );
      }
      if (widget.audioBookImage != null) {
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
    if (_audioPlayer == null) return;
    try {
      final audioUrl = widget.audioBookData['audio_file_url'];
      if (audioUrl == null || audioUrl.isEmpty) {
        _showSnackBar("Audio URL is missing or invalid.");
        return;
      }

      if (_isPlaying) {
        await _audioPlayer!.pause();
        await _saveAudioPosition();
      } else {
        await _audioPlayer!.setSource(UrlSource(audioUrl));
        await _audioPlayer!.seek(_currentPosition);
        await _audioPlayer!.resume();
      }
    } catch (e) {
      debugPrint('Playback error: $e');
      _showSnackBar("Failed to play audio.");
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
    final newPosition = Duration(seconds: (_currentPosition.inSeconds + 10).clamp(0, _totalDuration.inSeconds));
    await _seekToPosition(newPosition);
  }

  Future<void> _skipBackward() async {
    final newPosition = Duration(seconds: (_currentPosition.inSeconds - 10).clamp(0, _totalDuration.inSeconds));
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
      final codec = await ui.instantiateImageCodec(widget.audioBookImage!);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      int r = 0, g = 0, b = 0, count = 0;
      for (int i = 0; i < bytes.length; i += 40) {
        if (i + 2 < bytes.length) {
          r += bytes[i];
          g += bytes[i + 1];
          b += bytes[i + 2];
          count++;
        }
      }

      if (count > 0) {
        setState(() {
          _dominantColor = Color.fromARGB(255, (r ~/ count), (g ~/ count), (b ~/ count));
        });
      }
    } catch (e) {
      debugPrint('Color extraction error: $e');
    }
  }

  Future<void> _saveAudioPosition() async {
    if (!_prefsInitialized || _prefs == null) return;
    try {
      await _prefs!.setInt('audio_position_$_bookId', _currentPosition.inSeconds);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    _audioPlayer?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final accentColor = themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
        : Color.fromARGB(255, 210, 209, 224);

    return Scaffold(
      backgroundColor: themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 210, 209, 224)
                          : Color.fromARGB(255, 46, 48, 97),
      body: _isLoading
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
                    SizedBox(height: 20),

                    Center(
                  child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _dominantColor ?? accentColor.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.audioBookImage != null
                              ? Image.memory(
                                  widget.audioBookImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      ImageAssets.book,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  ImageAssets.book,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "${widget.audioBookData["name"]}".tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Author: ${widget.audioBookData["author"]}".tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: accentColor.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Publish Date: ${widget.audioBookData["publish date"]}".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: accentColor.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 30),

                    // Progress slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: accentColor,
                          inactiveTrackColor: accentColor.withOpacity(0.3),
                          thumbColor: accentColor,
                          overlayColor: accentColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _currentPosition.inSeconds.toDouble(),
                          min: 0,
                          // max: widget.audioBookData["audio_file_duration_seconds"].toDouble() > 0
                          //     ? widget.audioBookData["audio_file_duration_seconds"].toDouble()
                          //     : 1,
                          max: _totalDuration.inSeconds > 0
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
                            style: TextStyle(color: accentColor, fontSize: 14),
                          ),
                          Text(
                            _formatDuration(_totalDuration),
                            style: TextStyle(color: accentColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

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

                    SizedBox(height: 20),

                    SizedBox(
                      child: Row(
                        children: [
                          Icon(Icons.volume_down, color: accentColor, size: 20),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: accentColor,
                                inactiveTrackColor: accentColor.withOpacity(0.3),
                                thumbColor: accentColor,
                                overlayColor: accentColor.withOpacity(0.2),
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
                          SizedBox(width: 40),
                          Text(
                            "Speed: ",
                            style: TextStyle(color: accentColor, fontSize: 14),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<double>(
                              dropdownColor: Color.fromARGB(255, 40, 41, 61),
                              value: _playbackSpeed,
                              underline: SizedBox(),
                              style: TextStyle(color: accentColor, fontSize: 14),
                              items: _speedOptions.map((speed) {
                                return DropdownMenuItem<double>(
                                  value: speed,
                                  child: Text(
                                    ' ${speed}x',
                                    style: TextStyle(color: accentColor.withOpacity(1)),
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

                    SizedBox(height: 20),
                  ],
                  ),
    );
  }
}
