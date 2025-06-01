// ignore_for_file: file_names

import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'package:get/get.dart';
import '../view/HomePage.dart';
import '../core/classes/Library.dart';
import 'Profile.dart';
import '../view/Teachers.dart';
import '../core/classes/CustomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

final ThemeController themeController = Get.find<ThemeController>();
final LocaleController localeController = Get.find<LocaleController>();
String mainIP = "http://192.168.1.8:8000";

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<StatefulWidget> createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  static bool isNavBarVisible = true;

  final audioPlayer = AudioPlayer();
  final audioCache = AudioCache(prefix: 'assets/music/');
  bool isPlaying = false;
  bool isExpanded = false;
  List<String> previousSongs = [];
  String? currentSong;
  final List<String> allSongs = [
    'Stark.mp3',
    'Targaryan.mp3',
    'Lannister.mp3',
    'Greyjoy.mp3',
    'Baratheon.mp3',
    'Tully.mp3',
    'Tyrell.mp3',
    'Braken.mp3',
    'Arryn.mp3',
    'HighTower.mp3',
    'Forrester.mp3',
    'Martell.mp3',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    previousSongs.clear();
    super.dispose();
  }

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
    await audioPlayer.setSource(AssetSource('music/$songName'));
    await audioPlayer.resume();
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
        await audioPlayer.resume();
        setState(() {
          isPlaying = true;
        });
      }
    } else {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  Widget _buildMusicControls() {
    if (!isNavBarVisible) return const SizedBox.shrink(); // Hide controls when navbar is hidden

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
              backgroundColor: themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
              foregroundColor: themeController.initialTheme == Themes.customLightTheme
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
                  await audioPlayer.pause();
                } else {
                  await audioPlayer.resume();
                }
                setState(() {
                  isPlaying = !isPlaying;
                });
              },
              elevation: 0,
              mini: true,
              backgroundColor: themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
              foregroundColor: themeController.initialTheme == Themes.customLightTheme
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
              backgroundColor: themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
              foregroundColor: themeController.initialTheme == Themes.customLightTheme
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
          backgroundColor: themeController.initialTheme == Themes.customLightTheme
              ? Color.fromARGB(255, 40, 41, 61)
              : Color.fromARGB(255, 210, 209, 224),
          foregroundColor: themeController.initialTheme == Themes.customLightTheme
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      home: Scaffold(
        body: PersistentTabView(
          tabs: [
            PersistentTabConfig(
              screen: HomePage(),
              item: ItemConfig(
                activeForegroundColor: Color.fromARGB(255, 40, 41, 61),
                inactiveForegroundColor: Color.fromARGB(255, 153, 151, 188),
                inactiveBackgroundColor:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 210, 209, 224)
                        : Color.fromARGB(255, 46, 48, 97),
                icon: Icon(Icons.home),
                title: "Home".tr,
              ),
            ),
            PersistentTabConfig(
              screen: Teachers(),
              item: ItemConfig(
                activeForegroundColor: Color.fromARGB(255, 40, 41, 61),
                inactiveForegroundColor: Color.fromARGB(255, 153, 151, 188),
                inactiveBackgroundColor:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 210, 209, 224)
                        : Color.fromARGB(255, 46, 48, 97),
                icon: Icon(Icons.person),
                title: "Teachers".tr,
              ),
            ),
            PersistentTabConfig(
              screen: Library(),
              item: ItemConfig(
                activeForegroundColor: Color.fromARGB(255, 40, 41, 61),
                inactiveForegroundColor: Color.fromARGB(255, 153, 151, 188),
                inactiveBackgroundColor:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 210, 209, 224)
                        : Color.fromARGB(255, 46, 48, 97),
                icon: Icon(Icons.local_library_rounded),
                title: "Library".tr,
              ),
            ),
            PersistentTabConfig(
              screen: Profile(),
              item: ItemConfig(
                activeForegroundColor: Color.fromARGB(255, 40, 41, 61),
                inactiveForegroundColor: Color.fromARGB(255, 153, 151, 188),
                inactiveBackgroundColor:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 210, 209, 224)
                        : Color.fromARGB(255, 46, 48, 97),
                icon: Icon(Icons.person),
                title: "Profile".tr,
              ),
            ),
          ],
          navBarBuilder: (navBarConfig) => CustomNavBar(navBarConfig: navBarConfig),
        ),
        floatingActionButton: Container(
          width: 150,
          height: 40,
          margin: EdgeInsets.only(bottom: 58),
          child: _buildMusicControls(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

