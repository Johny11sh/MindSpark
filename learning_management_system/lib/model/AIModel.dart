// ignore_for_file: file_names

class AIModel {
  final String id;
  final String name;
  final String apiEndpoint;
  final List<String> languages;
  final String capabilities;
  final String limitations;
  final String recommendedUse;

  const AIModel({
    required this.id,
    required this.name,
    required this.apiEndpoint,
    required this.languages,
    required this.capabilities,
    required this.limitations,
    required this.recommendedUse,
  });

  @override
  String toString() => name;
}

class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const Message({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

class Chat {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });

  Chat copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

const availableAIModels = [
  AIModel(
    id: 'deepseek/deepseek-r1:free',
    name: 'DeepSeek R1',
    apiEndpoint: 'deepseek/deepseek-r1:free',
    languages: ['English', 'Arabic', 'French', 'Spanish', 'German'],
    capabilities: 'Advanced reasoning, long context (164k)',
    limitations: 'Large model, slower response',
    recommendedUse: 'Scientific explanations, multi-step and problem-solving',
  ),

  AIModel(
    id: 'mistralai/mistral-nemo:free',
    name: 'Mistral Nemo',
    apiEndpoint: 'mistralai/mistral-nemo:free',
    languages: ['English', 'Arabic', 'French', 'Spanish', 'German'],
    capabilities: 'Efficient inference, strong quality for reasoning',
    limitations: '8k context, smaller than DeepSeek',
    recommendedUse: 'Quick academic queries, multilingual support',
  ),
];
