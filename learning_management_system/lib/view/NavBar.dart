// ignore_for_file: file_names

import 'package:audioplayers/audioplayers.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
String mainIP = "http://192.168.1.9:8000";
// String mainIP = "http://127.0.0.1:8000";

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<StatefulWidget> createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  // static bool isNavBarVisible = true;
  // static AudioPlayer? audioPlayer;

  // final audioCache = AudioCache(prefix: 'assets/music/');
  // bool isPlaying = false;
  // bool isExpanded = false;
  // List<String> previousSongs = [];
  // String? currentSong;
  // final List<String> allSongs = [
  //   'Song1.mp3',
  //   'Song2.mp3',
  //   'Song3.mp3',
  //   'Song4.mp3',
  //   'Song5.mp3',
  //   'Song6.mp3',
  //   'Song7.mp3',
  //   'Song8.mp3',
  //   'Song9.mp3',
  //   'Song10.mp3',
  //   'Song11.mp3',
  //   'Song12.mp3',
  //   'Song13.mp3',
  //   'Song14.mp3',
  // ];

  // @override
  // void initState() {
  //   super.initState();
  //   audioPlayer = AudioPlayer();
  // }

  // @override
  // void dispose() {
  //   audioPlayer?.dispose();
  //   audioPlayer = null;
  //   previousSongs.clear();
  //   super.dispose();
  // }

  // String getRandomSong() {
  //   final random = Random();
  //   String song;
  //   do {
  //     song = allSongs[random.nextInt(allSongs.length)];
  //   } while (song == currentSong && allSongs.length > 1);
  //   return song;
  // }

  // Future<void> playSong(String songName) async {
  //   if (currentSong != null) {
  //     previousSongs.add(currentSong!);
  //   }
  //   currentSong = songName;
  //   await audioPlayer?.setSource(AssetSource('music/$songName'));
  //   await audioPlayer?.resume();
  //   setState(() {
  //     isPlaying = true;
  //   });
  // }

  // Future<void> playPreviousSong() async {
  //   if (previousSongs.isNotEmpty) {
  //     final previousSong = previousSongs.removeLast();
  //     await playSong(previousSong);
  //   }
  // }

  // Future<void> playNextSong() async {
  //   if (previousSongs.isNotEmpty) {
  //     previousSongs.clear();
  //   }
  //   final nextSong = getRandomSong();
  //   await playSong(nextSong);
  // }

  // void _toggleExpand() {
  //   setState(() {
  //     isExpanded = !isExpanded;
  //   });
  // }

  // void _handleMainButtonPress() async {
  //   _toggleExpand();

  //   if (!isPlaying) {
  //     if (currentSong == null) {
  //       // First time press - play random song
  //       await playNextSong();
  //     } else {
  //       // Resume current song
  //       await audioPlayer?.resume();
  //       setState(() {
  //         isPlaying = true;
  //       });
  //     }
  //   } else {
  //     await audioPlayer?.pause();
  //     setState(() {
  //       isPlaying = false;
  //     });
  //   }
  // }

  // Widget _buildMusicControls() {
  //   if (!isNavBarVisible) {
  //     // Ensure audio is paused when navbar is hidden
  //     audioPlayer?.pause();
  //     return const SizedBox.shrink();
  //   }

  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       if (isExpanded) ...[
  //         // Previous Button
  //         Positioned(
  //           left: 0,
  //           child: FloatingActionButton(
  //             onPressed: playPreviousSong,
  //             elevation: 0,
  //             mini: true,
  //             backgroundColor:
  //                 themeController.initialTheme == Themes.customLightTheme
  //                     ? Color.fromARGB(255, 40, 41, 61)
  //                     : Color.fromARGB(255, 210, 209, 224),
  //             foregroundColor:
  //                 themeController.initialTheme == Themes.customLightTheme
  //                     ? Color.fromARGB(255, 210, 209, 224)
  //                     : Color.fromARGB(255, 46, 48, 97),
  //             child: Icon(Icons.skip_previous_rounded, size: 22),
  //           ),
  //         ),
  //         // Play/Pause Button
  //         Positioned(
  //           child: FloatingActionButton(
  //             onPressed: () async {
  //               if (isPlaying) {
  //                 await audioPlayer?.pause();
  //               } else {
  //                 await audioPlayer?.resume();
  //               }
  //               setState(() {
  //                 isPlaying = !isPlaying;
  //               });
  //             },
  //             elevation: 0,
  //             mini: true,
  //             backgroundColor:
  //                 themeController.initialTheme == Themes.customLightTheme
  //                     ? Color.fromARGB(255, 40, 41, 61)
  //                     : Color.fromARGB(255, 210, 209, 224),
  //             foregroundColor:
  //                 themeController.initialTheme == Themes.customLightTheme
  //                     ? Color.fromARGB(255, 210, 209, 224)
  //                     : Color.fromARGB(255, 46, 48, 97),
  //             child: Icon(
  //               isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
  //               size: 22,
  //             ),
  //           ),
  //         ),
  //         // Next Button
  //         Positioned(
  //           right: 0,
  //           child: FloatingActionButton(
  //             onPressed: playNextSong,
  //             elevation: 0,
  //             mini: true,
  //             backgroundColor:
  //                 themeController.initialTheme == Themes.customLightTheme
  //                     ? Color.fromARGB(255, 40, 41, 61)
  //                     : Color.fromARGB(255, 210, 209, 224),
  //             foregroundColor:
  //                 themeController.initialTheme == Themes.customLightTheme
  //                     ? Color.fromARGB(255, 210, 209, 224)
  //                     : Color.fromARGB(255, 46, 48, 97),
  //             child: Icon(Icons.skip_next_rounded, size: 22),
  //           ),
  //         ),
  //       ],
  //       // Main Button
  //       FloatingActionButton(
  //         onPressed: _handleMainButtonPress,
  //         elevation: 2,
  //         mini: true,
  //         backgroundColor:
  //             themeController.initialTheme == Themes.customLightTheme
  //                 ? Color.fromARGB(255, 40, 41, 61)
  //                 : Color.fromARGB(255, 210, 209, 224),
  //         foregroundColor:
  //             themeController.initialTheme == Themes.customLightTheme
  //                 ? Color.fromARGB(255, 210, 209, 224)
  //                 : Color.fromARGB(255, 46, 48, 97),
  //         child: Icon(
  //           isExpanded ? Icons.music_off_rounded : Icons.music_note_rounded,
  //           size: 22,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  List pageName = [
    {"Name": "HomePage", "Icon": Icons.home_filled},

    {"Name": "Teachers", "Icon": Icons.person},

    {"Name": "Library", "Icon": Icons.local_library_rounded},

    {"Name": "Profile", "Icon": Icons.account_circle_outlined},
  ];

  List<Widget> page = [HomePage(), Teachers(), Library(), Profile()];

  int currentPage = 0;

  changePage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 120,
        // margin: EdgeInsets.only(bottom: 40),
        padding: EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          color:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 46, 48, 97)
                  : Color.fromARGB(255, 210, 209, 224),
          borderRadius: BorderRadius.circular(15),
          // color: Color.fromARGB(255, 210, 209, 224),
          boxShadow: [
            BoxShadow(
              color:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 46, 48, 97)
                      : Color.fromARGB(255, 210, 209, 224),
              offset: Offset(0, -1),
              spreadRadius: 0,
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: GNav(
            curve: Curves.easeOutExpo,
            duration: Duration(milliseconds: 200),
            gap: 4,
            color:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 46, 48, 97),
            // color: Color.fromARGB(255, 210, 209, 224),
            activeColor:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 46, 48, 97)
                    : Color.fromARGB(255, 210, 209, 224),

            // Color.fromARGB(255, 210, 209, 224),
            iconSize: 26,
            tabBackgroundColor:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 46, 48, 97),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            onTabChange: (index) {
              changePage(index);
            },
            tabs: [
              ...List.generate(page.length, (index) {
                return GButton(
                  text: pageName[index]["Name"],

                  icon: pageName[index]["Icon"],
                );
              }),
            ],
          ),
        ),
      ),
      body: page.elementAt(currentPage),
      
    );
  }
}
