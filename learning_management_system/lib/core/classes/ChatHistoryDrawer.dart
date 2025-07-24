// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../model/AIModel.dart';
import '../../themes/Themes.dart';
import '../../view/NavBar.dart';

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
      child: Container (
              color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 210, 209, 224)
          : Color.fromARGB(255, 46, 48, 97),
               child : Column(
        children: [
          DrawerHeader(
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat History',
                  style: TextStyle(
                    color: themeController.initialTheme == Themes.customLightTheme
        ? Color.fromARGB(255, 40, 41, 61)
        : Color.fromARGB(255, 210, 209, 224),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your previous conversations',
                  style: TextStyle(
                    color: themeController.initialTheme == Themes.customLightTheme
        ? Color.fromARGB(255, 40, 41, 61)
        : Color.fromARGB(255, 210, 209, 224),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: chats.isEmpty
                ? Center(
                    child: Text(
                      'No chat history yet',
                      style: TextStyle(
                        color: themeController.initialTheme == Themes.customLightTheme
        ? Color.fromARGB(255, 40, 41, 61)
        : Color.fromARGB(255, 210, 209, 224),
                        fontSize: 16,
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
                          color: themeController.initialTheme == Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                        ),
                        title: Text(
                          chat.title.isNotEmpty ? chat.title : 'New Chat',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: themeController.initialTheme == Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatDate(chat.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: themeController.initialTheme == Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                          ),
                        ),
                        // trailing: Text(
                        //   '${chat.messages.length}',
                        //   style: const TextStyle(
                        //     color: Colors.grey,
                        //     fontSize: 12,
                        //   ),
                        // ),
                        onTap: () => onChatSelected(chat),
                      );
                    },
                  ),
          ),
        ],
      ),)
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