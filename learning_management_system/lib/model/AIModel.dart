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
  languages: ['en', 'ar', 'fr', 'es', 'de'],
  capabilities: 'Advanced reasoning, long context (164k)',
  limitations: 'Large model, slower response',
  recommendedUse: 'Scientific explanations, multi-step problem-solving',
),

// AIModel(
//   id: 'deepseek/deepseek-chat:free',
//   name: 'DeepSeek V3 Chat',
//   apiEndpoint: 'deepseek/deepseek-chat:free',
//   languages: ['en', 'ar', 'fr', 'es', 'de'],
//   capabilities: 'Instruction-following, coding & reasoning',
//   limitations: 'Medium context (164k), slightly less reasoning than R1',
//   recommendedUse: 'Interactive Q&A, coding help, general science',
// ),

AIModel(
  id: 'mistralai/mistral-nemo:free',
  name: 'Mistral Nemo',
  apiEndpoint: 'mistralai/mistral-nemo:free',
  languages: ['en', 'ar', 'fr', 'es', 'de'],
  capabilities: 'Efficient inference, strong quality for reasoning',
  limitations: '8k context, smaller than DeepSeek',
  recommendedUse: 'Quick academic queries, multilingual support',
),

// AIModel(
//   id: 'mistralai/mistral-small-3.2-24b:free',
//   name: 'Mistral Small 3.2‑24B',
//   apiEndpoint: 'mistralai/mistral-small-3.2-24b:free',
//   languages: ['en', 'ar', 'fr', 'es', 'de'],
//   capabilities: 'Large context (96k), strong logic & structure',
//   limitations: 'Requires slightly more compute, still efficient',
//   recommendedUse: 'Deep academic discussions, long-form responses',
// ),

// AIModel(
//   id: 'google/gemma-3n-2b:free',
//   name: 'Google Gemma 3n 2B',
//   apiEndpoint: 'google/gemma-3n-2b:free',
//   languages: ['en', 'ar', 'fr', 'es', 'de'],
//   capabilities: 'Fast responses, text + image reasoning',
//   limitations: 'Small model, fewer tokens/context',
//   recommendedUse: 'Fact retrieval, quick educational answers',
// ),

  // AIModel(
  //   id: 'mistral7b',
  //   name: 'Mistral 7B',
  //   apiEndpoint: 'mistralai/Mistral-7B-Instruct-v0.1',
  //   languages: ['en', 'ar', 'fr', 'es', 'de'],
  //   capabilities: 'Strong reasoning, good multilingual support',
  //   limitations: 'Limited context window (8k tokens)',
  //   recommendedUse: 'General academic Q&A, multilingual support',
  // ),
  // AIModel(
  //   id: 'llama3-8b',
  //   name: 'Llama 3 (8B)',
  //   apiEndpoint: 'meta-llama/Meta-Llama-3-8B-Instruct',
  //   languages: ['en', 'es', 'fr', 'de'],
  //   capabilities: 'Excellent instruction following, up-to-date knowledge',
  //   limitations: 'Weaker in Arabic than Mistral',
  //   recommendedUse: 'Structured academic responses, STEM subjects',
  // ),
  // AIModel(
  //   id: 'llama2-7b',
  //   name: 'Llama 2 (7B)',
  //   apiEndpoint: 'meta-llama/Llama-2-7b-chat-hf',
  //   languages: ['en', 'es', 'fr'],
  //   capabilities: 'Reliable performance, good safety filters',
  //   limitations: 'Older model, smaller context',
  //   recommendedUse: 'Basic course questions, conservative content',
  // ),
  // AIModel(
  //   id: 'zephyr7b',
  //   name: 'Zephyr 7B',
  //   apiEndpoint: 'HuggingFaceH4/zephyr-7b-beta',
  //   languages: ['en', 'fr', 'es'],
  //   capabilities: 'Conversational, helpful tone',
  //   limitations: 'Limited multilingual support',
  //   recommendedUse: 'Student tutoring, explanation of concepts',
  // ),
  // AIModel(
  //   id: 'arabic-mt5',
  //   name: 'Arabic mT5',
  //   apiEndpoint: 'UBC-NLP/AraT5-base-Arabic-Chat',
  //   languages: ['ar', 'en'],
  //   capabilities: 'Specialized for Arabic content',
  //   limitations: 'Weak in other languages',
  //   recommendedUse: 'Arabic language subjects, Islamic studies',
  // ),
];