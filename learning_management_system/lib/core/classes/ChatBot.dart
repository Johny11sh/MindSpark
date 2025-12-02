// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/BackButtonController.dart';
import '../../model/AIModel.dart';
import '../../services/ChatService.dart';
import '../../themes/Themes.dart';
import '../../view/NavBar.dart';
import 'ChatHistoryDrawer.dart';
import '../constants/FontGlobals.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final ChatService _chatService = ChatService();
  final BackButtonController controller = Get.put(BackButtonController());

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  AIModel get _selectedModel => _chatService.currentModel;

  @override
  void initState() {
    super.initState();
    _chatService.setCurrentModel(availableAIModels.first);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.onWillPop,

      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 153, 151, 188)
                  : Color.fromARGB(255, 40, 41, 61),
          title: Text(
                'Sparky AI Assistant'.tr,
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 22
                          : 22 - (globalFontSizeChange / 5),
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                ),
              )
              .animate(onPlay: (controller) => controller.loop())
              .shimmer(
                delay: Duration(seconds: 4),
                duration: 800.ms,
                color:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Colors.grey.shade700
                        : Colors.white54,
              ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.post_add_rounded,
                color:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 40, 41, 61)
                        : Color.fromARGB(255, 210, 209, 224),
                size: 25,
              ),
              onPressed: _startNewChat,
              tooltip: 'New Chat'.tr,
            ),
          ],
        ),
        drawer: ChatHistoryDrawer(
          chats: _chatService.chatHistory,
          onChatSelected: _loadChat,
        ),

        drawerScrimColor:
            themeController.initialTheme == Themes.customLightTheme
                ? Color.fromARGB(255, 40, 41, 61)
                : Color.fromARGB(255, 210, 209, 224),

        body: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 6, child: _buildModelHeader()),
                Expanded(
                  flex: 5,
                  child:
                      _isLoading
                          ? _buildLoadingIndicator()
                          : _buildModelSelector(),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                "Sparky Academic AI Assistant".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 16
                          : 16 - (globalFontSizeChange / 5),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                "Got a rule in need of explaining? Some concepts to dissect? Ask our sophisticated chatbot which will have the answer to every question in your mind!"
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 14
                          : 14 - (globalFontSizeChange / 5),
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                "It will guide you through your learning journey, giving you the right ways of studying and understanding each piece of information."
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 12
                          : 12 - (globalFontSizeChange / 5),
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                "Only educational questions are allowed, any other types will be rejected respectfully."
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 14
                          : 14 - (globalFontSizeChange / 5),
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            // const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Divider(height: 30, thickness: 1),
            ),

            Expanded(
              child: DashChat(
                currentUser: _getCurrentUser(),
                messageOptions: MessageOptions(
                  showTime: true,
                  onLongPressMessage: (p0) {
                    Clipboard.setData(ClipboardData(text: p0.text));
                  },
                  maxWidth: Get.width * (0.7),
                  timeFormat: DateFormat('HH:mm'),
                  avatarBuilder: (user, message, onMessageAvatarTap) {
                    final isUser = user.id == '1';
                    return CircleAvatar(
                      backgroundColor: isUser ? Colors.blue : Colors.grey[300],
                      child: Icon(
                        isUser ? Icons.person : Icons.auto_awesome,
                        color: isUser ? Colors.white : Colors.grey[600],
                      ),
                    );
                  },
                ),
                inputOptions: InputOptions(
                  inputTextStyle: TextStyle(
                    fontSize:
                        globalFontSizeChange <= 17
                            ? (globalFontSizeChange / 5) + 16
                            : 16.0 - (globalFontSizeChange / 5),
                  ),
                  sendButtonBuilder: _buildSendButton,
                  inputDecoration: InputDecoration(
                    hintText: 'Ask about your courses...'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                messages: _convertToDashChatMessages().reversed.toList(),
                onSend: (ChatMessage message) => _sendMessage(message),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelInfoButton() {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed:
          () => showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    _selectedModel.name,
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      color: Color.fromARGB(255, 40, 41, 61),
                      fontWeight: FontWeight.w500,
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 20
                              : 20 - (globalFontSizeChange / 5),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row(children: [
                        Text(
                          'Capabilities: '.tr,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 85, 81, 132),
                            fontWeight: FontWeight.w500,
                            fontFamily: globalFontFamily,
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 18
                                    : 18 - (globalFontSizeChange / 5),
                          ),
                        ),
                        Text(
                          _selectedModel.capabilities,
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color: const Color.fromARGB(255, 40, 41, 61),
                          ),
                        ),
                        // ],),
                        const SizedBox(height: 8),
                        // Row(children: [
                        Text(
                          'Limitations: '.tr,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 85, 81, 132),
                            fontWeight: FontWeight.w500,
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 18
                                    : 18 - (globalFontSizeChange / 5),
                            fontFamily: globalFontFamily,
                          ),
                        ),
                        Text(
                          _selectedModel.limitations,
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color: const Color.fromARGB(255, 40, 41, 61),
                          ),
                        ),
                        // ],),
                        const SizedBox(height: 8),
                        // Row(children: [
                        Text(
                          'Recommended for: '.tr,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 85, 81, 132),
                            fontWeight: FontWeight.w500,
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 18
                                    : 18 - (globalFontSizeChange / 5),
                            fontFamily: globalFontFamily,
                          ),
                        ),
                        Text(
                          _selectedModel.recommendedUse,
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color: const Color.fromARGB(255, 40, 41, 61),
                          ),
                        ),
                        // ],),
                        const SizedBox(height: 12),
                        // Row(children: [
                        Text(
                          'Supported Languages: '.tr,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 85, 81, 132),
                            fontWeight: FontWeight.w500,
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 18
                                    : 18 - (globalFontSizeChange / 5),
                            fontFamily: globalFontFamily,
                          ),
                        ),
                        Text(
                          _selectedModel.languages.join(', '),
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color: const Color.fromARGB(255, 40, 41, 61),
                          ),
                        ),
                        // ],),

                        // Text('Capabilities: ${_selectedModel.capabilities}'),
                        // const SizedBox(height: 8),
                        // Text('Limitations: ${_selectedModel.limitations}'),
                        // const SizedBox(height: 8),
                        // Text('Recommended for: ${_selectedModel.recommendedUse}'),
                        // const SizedBox(height: 12),
                        // Text('Supported Languages: ${_selectedModel.languages.join(', ')}'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'OK'.tr,
                        style: TextStyle(fontFamily: globalFontFamily),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildModelHeader() {
    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(0.6),

      color: Colors.blue[50],
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.auto_awesome, size: 16),
          const SizedBox(width: 8),
          Text(
            'For More Info'.tr,
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 16
                      : 16 - (globalFontSizeChange / 5),
              fontFamily: globalFontFamily,
              color: Color.fromARGB(255, 40, 41, 61),
            ),
          ),
          // Text(
          //   'Using: ${_selectedModel.name}',
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),
          // SizedBox(width:15),
          _buildModelInfoButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[600]!,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is thinking...'.tr,
                  style: TextStyle(
                    color: Colors.grey[600],
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
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      // padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Container(
        // decoration: BoxDecoration(
        //   border: Border.all(color: Colors.blue.shade100),
        //   borderRadius: BorderRadius.circular(8),
        // ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButton<AIModel>(
          value: _selectedModel,
          isExpanded: true,
          underline: const SizedBox(),
          items:
              availableAIModels.map((model) {
                return DropdownMenuItem<AIModel>(
                  value: model,
                  child: Text(
                    model.name,
                    style: TextStyle(
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 14
                              : 14 - (globalFontSizeChange / 5),
                      fontFamily: globalFontFamily,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (model) => model != null ? _changeModel(model) : null,
        ),
      ),
    );
  }

  Widget _buildSendButton(Function send) {
    return IconButton(
      icon: const Icon(Icons.send, color: Colors.blue),
      onPressed: () => send(),
    );
  }

  ChatUser _getCurrentUser() {
    return ChatUser(id: '1', firstName: 'You'.tr, lastName: '');
  }

  List<ChatMessage> _convertToDashChatMessages() {
    return _chatService.currentChat.messages.map((message) {
      return ChatMessage(
        text: message.text,
        user: message.isMe ? _getCurrentUser() : _getBotUser(),
        createdAt: message.timestamp,
      );
    }).toList();
  }

  ChatUser _getBotUser() {
    return ChatUser(id: '2', firstName: _selectedModel.name.tr, lastName: '');
  }

  Future<void> _sendMessage(ChatMessage message) async {
    if (message.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final userMessage = Message(
      text: message.text,
      isMe: true,
      timestamp: message.createdAt,
    );
    _chatService.addMessageToCurrentChat(userMessage);

    try {
      final botResponse = await _chatService.getBotResponse(message.text);
      _chatService.addMessageToCurrentChat(botResponse);
    } catch (e) {
      _chatService.addMessageToCurrentChat(
        Message(
          text: 'Error: ${e.toString()}',
          isMe: false,
          timestamp: DateTime.now(),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _startNewChat() {
    setState(() {
      _chatService.startNewChat();
    });
  }

  void _loadChat(Chat chat) {
    try {
      setState(() => _chatService.setCurrentChat(chat));

      // Update the chat title based on the first message
      String newTitle;
      if (_chatService.currentChat.messages.isNotEmpty) {
        final firstMessage = _chatService.currentChat.messages[0].text;
        if (firstMessage.isNotEmpty) {
          newTitle =
              firstMessage.length > 20
                  ? '${firstMessage.substring(0, 20)}...'
                  : firstMessage;
        } else {
          newTitle = "New Chat".tr;
        }
      } else {
        newTitle = "New Chat".tr;
      }

      // Create a new chat object with the updated title
      final updatedChat = _chatService.currentChat.copyWith(title: newTitle);
      _chatService.updateCurrentChat(updatedChat);

      Navigator.pop(context);
    } catch (e) {
      // If there's any error, just close the drawer
      Navigator.pop(context);
    }
  }

  void _changeModel(AIModel model) {
    setState(() {
      _chatService.setCurrentModel(model);
    });
  }
}
