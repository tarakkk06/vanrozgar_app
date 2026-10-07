enum MessageSender {
  user,
  assistant,
  system,
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final String? audioText; // For speech synthesis in Marathi/Hindi/English
  final DateTime timestamp;
  final bool hasNumber;
  final bool numberRulePassed;
  final String? sourceCitation;
  final String? sourceDate;
  final String? calculatedFormula;
  final List<String> actionableTips;
  final bool isAudioPlaying;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.audioText,
    DateTime? timestamp,
    this.hasNumber = false,
    this.numberRulePassed = true,
    this.sourceCitation,
    this.sourceDate,
    this.calculatedFormula,
    this.actionableTips = const [],
    this.isAudioPlaying = false,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? text,
    String? audioText,
    DateTime? timestamp,
    bool? hasNumber,
    bool? numberRulePassed,
    String? sourceCitation,
    String? sourceDate,
    String? calculatedFormula,
    List<String>? actionableTips,
    bool? isAudioPlaying,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      audioText: audioText ?? this.audioText,
      timestamp: timestamp ?? this.timestamp,
      hasNumber: hasNumber ?? this.hasNumber,
      numberRulePassed: numberRulePassed ?? this.numberRulePassed,
      sourceCitation: sourceCitation ?? this.sourceCitation,
      sourceDate: sourceDate ?? this.sourceDate,
      calculatedFormula: calculatedFormula ?? this.calculatedFormula,
      actionableTips: actionableTips ?? this.actionableTips,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
    );
  }
}
