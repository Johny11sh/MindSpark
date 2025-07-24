// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:learning_management_system/core/classes/Timer.dart';
import 'package:path/path.dart';
import '../../themes/Themes.dart';
import 'package:get/get.dart';
import '../../themes/ThemeController.dart';

class PDFOpener extends StatefulWidget {
  final File PDFfile;
   PDFOpener({super.key, required this.PDFfile});

 

  @override
  State<PDFOpener> createState() => _PDFOpenerState();
}

class _PDFOpenerState extends State<PDFOpener> {


  late PDFViewController pdfViewController;
  int pages = 0;
  int pageIndex = 0;
  bool isLoading = true;
  final ThemeController themeController = Get.find<ThemeController>();
  bool isDragging = false;
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;


  static AudioPlayer? audioPlayer;

  final audioCache = AudioCache(prefix: 'assets/music/');
  bool isPlaying = false;
  bool isExpanded = false;
  List<String> previousSongs = [];
  String? currentSong;
  final List<String> allSongs = [
    'Song1.mp3',
    'Song2.mp3',
    'Song3.mp3',
    'Song4.mp3',
    'Song5.mp3',
    'Song6.mp3',
    'Song7.mp3',
    'Song8.mp3',
    'Song9.mp3',
    'Song10.mp3',
    'Song11.mp3',
    'Song12.mp3',
    'Song13.mp3',
    'Song14.mp3',
  ];


  String getRandomSong() {
    final random = Random();
    String song;
    do {
      song = allSongs[random.nextInt(allSongs.length)];
    } while (song == currentSong && allSongs.length > 1);
    return song;
  }

  Future<void> playSong(String songName) async {
    if (currentSong != null) {
      previousSongs.add(currentSong!);
    }
    currentSong = songName;
    await audioPlayer?.setSource(AssetSource('music/$songName'));
    await audioPlayer?.resume();
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> playPreviousSong() async {
    if (previousSongs.isNotEmpty) {
      final previousSong = previousSongs.removeLast();
      await playSong(previousSong);
    }
  }

  Future<void> playNextSong() async {
    if (previousSongs.isNotEmpty) {
      previousSongs.clear();
    }
    final nextSong = getRandomSong();
    await playSong(nextSong);
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _handleMainButtonPress() async {
    _toggleExpand();

    if (!isPlaying) {
      if (currentSong == null) {
        // First time press - play random song
        await playNextSong();
      } else {
        // Resume current song
        await audioPlayer?.resume();
        setState(() {
          isPlaying = true;
        });
      }
    } else {
      await audioPlayer?.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  Widget _buildMusicControls() {
    
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isExpanded) ...[
          // Previous Button
          Positioned(
            left: 0,
            child: FloatingActionButton(
              onPressed: playPreviousSong,
              elevation: 0,
              mini: true,
              backgroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 40, 41, 61)
                      : Color.fromARGB(255, 210, 209, 224),
              foregroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 46, 48, 97),
              child: Icon(Icons.skip_previous_rounded, size: 22),
            ),
          ),
          // Play/Pause Button
          Positioned(
            child: FloatingActionButton(
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer?.pause();
                } else {
                  await audioPlayer?.resume();
                }
                setState(() {
                  isPlaying = !isPlaying;
                });
              },
              elevation: 0,
              mini: true,
              backgroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 40, 41, 61)
                      : Color.fromARGB(255, 210, 209, 224),
              foregroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 46, 48, 97),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 22,
              ),
            ),
          ),
          // Next Button
          Positioned(
            right: 0,
            child: FloatingActionButton(
              onPressed: playNextSong,
              elevation: 0,
              mini: true,
              backgroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 40, 41, 61)
                      : Color.fromARGB(255, 210, 209, 224),
              foregroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 46, 48, 97),
              child: Icon(Icons.skip_next_rounded, size: 22),
            ),
          ),
        ],
        // Main Button
        FloatingActionButton(
          onPressed: _handleMainButtonPress,
          elevation: 2,
          mini: true,
          backgroundColor:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
          foregroundColor:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 210, 209, 224)
                  : Color.fromARGB(255, 46, 48, 97),
          child: Icon(
            isExpanded ? Icons.music_off_rounded : Icons.music_note_rounded,
            size: 22,
          ),
        ),
      ],
    );
  }



  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _preloadPDF();
    audioPlayer = AudioPlayer();

  }


  String _formatFileName(String name) {
    if (name.toLowerCase().endsWith('.pdf')) {
      return name.substring(0, name.length - 4);
    }
    return name;
  }


  Future<void> _preloadPDF() async {
    if (_isDisposed) return;

    try {
      final file = widget.PDFfile;
      if (await file.exists()) {
        if (!_isDisposed) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error preloading PDF: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    audioPlayer?.dispose();
    audioPlayer = null;
    previousSongs.clear();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _formatFileName(basename(widget.PDFfile.path));
    return Scaffold(
      floatingActionButton:Container(
                width: 150,
                height: 40,
                margin: EdgeInsets.only(bottom: 10),
                child: _buildMusicControls(),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: themeController.initialTheme == Themes.customLightTheme
          ? const Color.fromARGB(255, 40, 41, 61)
          : const Color.fromARGB(255, 210, 209, 224),
      appBar: AppBar(
        backgroundColor: themeController.initialTheme == Themes.customLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224),
        title: Text(
          name,
          style: TextStyle(
            color: themeController.initialTheme == Themes.customLightTheme
                ? const Color.fromARGB(255, 210, 209, 224)
                : const Color.fromARGB(255, 40, 41, 61),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeController.initialTheme == Themes.customLightTheme
                ? const Color.fromARGB(255, 210, 209, 224)
                : const Color.fromARGB(255, 40, 41, 61),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (pages > 0) ...[
            IconButton(
              onPressed: () {
                final page = pageIndex == 0 ? pages : pageIndex - 1;
                pdfViewController.setPage(page);
              },
              icon: Icon(
                Icons.chevron_left_outlined,
                size: 26,
                color: themeController.initialTheme == Themes.customLightTheme
                    ? const Color.fromARGB(255, 210, 209, 224)
                    : const Color.fromARGB(255, 40, 41, 61),
              ),
            ),
            if (pages > 0)
              Text(
                '${pageIndex + 1} of $pages',
                style: TextStyle(
                  fontSize: 12,
                  color: themeController.initialTheme == Themes.customLightTheme
                      ? const Color.fromARGB(255, 210, 209, 224)
                      : const Color.fromARGB(255, 40, 41, 61),
                ),
              ),
            IconButton(
              onPressed: () {
                final page = pageIndex == pages - 1 ? 0 : pageIndex + 1;
                pdfViewController.setPage(page);
              },
              icon: Icon(
                Icons.chevron_right_outlined,
                size: 26,
                color: themeController.initialTheme == Themes.customLightTheme
                    ? const Color.fromARGB(255, 210, 209, 224)
                    : const Color.fromARGB(255, 40, 41, 61),
              ),
            ),
            IconButton(
              onPressed: () {
                Get.dialog(

                                        TimerView(),
                                        barrierColor: Colors.transparent
                                      );
              },
              icon: Icon(
                Icons.timer,
                size: 26,
                color: themeController.initialTheme == Themes.customLightTheme
                    ? const Color.fromARGB(255, 210, 209, 224)
                    : const Color.fromARGB(255, 40, 41, 61),
              ),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.PDFfile.path,
            swipeHorizontal: false,
            pageSnap: false,
            autoSpacing: true,
            pageFling: false,
            preventLinkNavigation: false,
            onRender: (pages) {
              if (!_isDisposed) {
                setState(() {
                  this.pages = pages!;
                  isLoading = false;
                });
              }
            },
            onViewCreated: (pdfViewController) {
              if (!_isDisposed) {
                setState(() {
                  this.pdfViewController = pdfViewController;
                });
              }
            },
            onPageChanged: (pageIndex, _) {
              if (!_isDisposed) {
                setState(() {
                  this.pageIndex = pageIndex!;
                });
              }
            },
            onError: (error) {
              debugPrint('Error loading PDF: $error');
              if (!_isDisposed) {
                Get.snackbar(
                  'Error'.tr,
                  'Failed to load PDF'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            onPageError: (page, error) {
              debugPrint('Error loading page $page: $error');
            },
            enableSwipe: true,
            fitPolicy: FitPolicy.BOTH,
            defaultPage: 0,
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: themeController.initialTheme == Themes.customLightTheme
                    ? const Color.fromARGB(255, 210, 209, 224)
                    : const Color.fromARGB(255, 40, 41, 61),
              ),
            ),
          if (pages > 0)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 8,
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: themeController.initialTheme == Themes.customLightTheme
                          ? const Color.fromARGB(255, 210, 209, 224).withOpacity(0.5)
                          : const Color.fromARGB(255, 40, 41, 61).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: GestureDetector(
                      onVerticalDragStart: (_) => setState(() => isDragging = true),
                      onVerticalDragEnd: (_) => setState(() => isDragging = false),
                      onVerticalDragUpdate: (details) {
                        if (pages > 0) {
                          final screenHeight = MediaQuery.of(context).size.height * 0.7;
                          final dragPercentage = details.localPosition.dy / screenHeight;
                          final targetPage = (dragPercentage * (pages - 1)).floor();
                          if (targetPage >= 0 && targetPage < pages) {
                            pdfViewController.setPage(targetPage);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (isDragging && pages > 0)
            Positioned(
              right: 50,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeController.initialTheme == Themes.customLightTheme
                        ? const Color.fromARGB(255, 40, 41, 61)
                        : const Color.fromARGB(255, 210, 209, 224),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${pageIndex + 1}',
                    style: TextStyle(
                      color: themeController.initialTheme == Themes.customLightTheme
                          ? const Color.fromARGB(255, 210, 209, 224)
                          : const Color.fromARGB(255, 40, 41, 61),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

    );
  }
}
