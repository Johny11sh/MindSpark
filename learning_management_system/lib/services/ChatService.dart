import 'dart:math';
import '../model/AIModel.dart';
import 'ApiService.dart';

class ChatService {
  final ApiService _apiService = ApiService();
  final List<Chat> _chatHistory = [];
  late Chat _currentChat;

  ChatService() {
    startNewChat();
  }

  List<Chat> get chatHistory => List.unmodifiable(_chatHistory);
  Chat get currentChat => _currentChat;
  AIModel get currentModel => _apiService.currentModel;

  void setCurrentModel(AIModel model) {
    _apiService.setModel(model);
  }

  void setCurrentChat(Chat chat) {
    _currentChat = chat;
  }

  void startNewChat() {
    final newChat = Chat(
      id: _generateChatId(),
      title: 'New Chat',
      messages: [],
      createdAt: DateTime.now(),
    );
    
    _currentChat = newChat;
    _chatHistory.insert(0, newChat);
  }

  void addMessageToCurrentChat(Message message) {
    final updatedMessages = List<Message>.from(_currentChat.messages)..add(message);
    _currentChat = _currentChat.copyWith(messages: updatedMessages);
    
    final index = _chatHistory.indexWhere((chat) => chat.id == _currentChat.id);
    if (index != -1) {
      _chatHistory[index] = _currentChat;
    }
    
    // Update title when first user message is added
    if (message.isMe && _currentChat.messages.length == 1) {
      final title = message.text.isNotEmpty && message.text.length > 30 
          ? '${message.text.substring(0, 30)}...' 
          : (message.text.isNotEmpty ? message.text : 'New Chat');
      _currentChat = _currentChat.copyWith(title: title);
      if (index != -1) {
        _chatHistory[index] = _currentChat;
      }
    }
  }

  Future<Message> getBotResponse(String userMessage) async {
    try {
      final response = await _apiService.getResponse(userMessage);
      return Message(
        text: response,
        isMe: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return Message(
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isMe: false,
        timestamp: DateTime.now(),
      );
    }
  }

  void deleteChat(String chatId) {
    _chatHistory.removeWhere((chat) => chat.id == chatId);
    if (_currentChat.id == chatId && _chatHistory.isNotEmpty) {
      _currentChat = _chatHistory.first;
    } else if (_chatHistory.isEmpty) {
      startNewChat();
    }
  }

  void updateCurrentChat(Chat updatedChat) {
    _currentChat = updatedChat;
    final index = _chatHistory.indexWhere((chat) => chat.id == _currentChat.id);
    if (index != -1) {
      _chatHistory[index] = _currentChat;
    }
  }

  Chat? getChatById(String chatId) {
    try {
      return _chatHistory.firstWhere((chat) => chat.id == chatId);
    } catch (e) {
      return null;
    }
  }

  void clearAllChats() {
    _chatHistory.clear();
    startNewChat();
  }

  Map<String, dynamic> exportChatHistory() {
    return {
      'chats': _chatHistory.map((chat) => {
        'id': chat.id,
        'title': chat.title,
        'createdAt': chat.createdAt.toIso8601String(),
        'messages': chat.messages.map((msg) => {
          'text': msg.text,
          'isMe': msg.isMe,
          'timestamp': msg.timestamp.toIso8601String(),
        }).toList(),
      }).toList(),
    };
  }

  String _generateChatId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
} 