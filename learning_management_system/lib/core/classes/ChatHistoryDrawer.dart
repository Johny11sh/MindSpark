// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../model/AIModel.dart';
import '../../themes/Themes.dart';
import '../../view/NavBar.dart';
import '../constants/FontGlobals.dart';

class ChatHistoryDrawer extends StatelessWidget {
  final List<Chat> chats;
  final Function(Chat) onChatSelected;

  const ChatHistoryDrawer({
    super.key,
    required this.chats,
    required this.onChatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color:
            themeController.initialTheme == Themes.customLightTheme
                ? Color.fromARGB(255, 210, 209, 224)
                : Color.fromARGB(255, 46, 48, 97),
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Chat History',
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 24
                              : 24 - (globalFontSizeChange / 5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const SizedBox(height: 8),

                  // ListTile(
                  //   leading: Icon(
                  //     Icons.chat_bubble_outline,
                  //     color:
                  //         themeController.initialTheme ==
                  //                 Themes.customLightTheme
                  //             ? Color.fromARGB(255, 40, 41, 61)
                  //             : Color.fromARGB(255, 210, 209, 224),
                  //   ),
                  //   title: Text(
                  //     'Saved Messages',
                  //     style: TextStyle(
                  //       fontSize:  globalFontSizeChange <= 17 ?(globalFontSizeChange/5) + 15 : 15 - (globalFontSizeChange / 5),
                  //       fontWeight: FontWeight.w500,
                  //       color:
                  //           themeController.initialTheme ==
                  //                   Themes.customLightTheme
                  //               ? Color.fromARGB(255, 40, 41, 61)
                  //               : Color.fromARGB(255, 210, 209, 224),
                  //     ),
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  //   onTap: () => onChatSelected(),
                  // ),
                  const SizedBox(height: 8),
                  Text(
                    'Your previous conversations',
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                      fontWeight: FontWeight.w500,
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 16
                              : 16 - (globalFontSizeChange / 5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Note: Chat history will be cleared at the end of the session.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                      fontWeight: FontWeight.w400,

                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 14
                              : 14 - (globalFontSizeChange / 5),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  chats.isEmpty
                      ? Center(
                        child: Text(
                          'No chat history yet',
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
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return ListTile(
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                            title: Text(
                              chat.title.isNotEmpty ? chat.title : 'New Chat',
                              style: TextStyle(
                                fontFamily: globalFontFamily,
                                fontSize:
                                    globalFontSizeChange <= 17
                                        ? (globalFontSizeChange / 5) + 15
                                        : 15 - (globalFontSizeChange / 5),
                                fontWeight: FontWeight.w500,
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _formatDate(chat.createdAt),
                              style: TextStyle(
                                fontFamily: globalFontFamily,
                                fontSize:
                                    globalFontSizeChange <= 17
                                        ? (globalFontSizeChange / 5) + 12
                                        : 12 - (globalFontSizeChange / 5),
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                              ),
                            ),
                            onTap: () => onChatSelected(chat),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return 'This week';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
