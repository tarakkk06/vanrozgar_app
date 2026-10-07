import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/voice_wave_visualizer.dart';
import '../widgets/trust_label_badge.dart';

class VoiceAiAssistantScreen extends StatefulWidget {
  const VoiceAiAssistantScreen({Key? key}) : super(key: key);

  @override
  State<VoiceAiAssistantScreen> createState() => _VoiceAiAssistantScreenState();
}

class _VoiceAiAssistantScreenState extends State<VoiceAiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _marathiSuggestedQueries = [
    'आमच्या गावात कोणता व्यवसाय करावा?',
    'बांबू प्रक्रिया केंद्रासाठी काय लागेल?',
    'तलावात मत्स्यपालनाचा नफा किती होईल?',
    'शेळीपालनासाठी कोणती शासकीय योजना आहे?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final messages = provider.chatHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.secondaryOrange.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.record_voice_over, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marathi Voice AI (मराठी व्हॉईस AI)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  'Bhashini STT • Strict Number Rule Active',
                  style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            tooltip: 'About Number Rule',
            onPressed: () => _showNumberRuleDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Voice Assistant Visualizer Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(bottom: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.langCode == 'mr'
                          ? 'बोला किंवा टाइप करा (Marathi Supported)'
                          : 'Speak or Type in Marathi / Hindi / English',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      ),
                      const Text(
                        'Verified agmarknet prices & CFR forest rules applied.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                VoiceWaveVisualizer(
                  isRecording: provider.isVoiceRecording,
                  isPlaying: messages.any((m) => m.isAudioPlaying),
                ),
              ],
            ),
          ),

          // Suggested Prompts Horizontal Bar
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: AppColors.background,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _marathiSuggestedQueries.length,
              itemBuilder: (context, index) {
                final q = _marathiSuggestedQueries[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  child: ActionChip(
                    label: Text(q, style: const TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onPressed: () {
                      provider.sendChatMessage(q);
                      _scrollToBottom();
                    },
                  ),
                );
              },
            ),
          ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(context, provider, msg);
              },
            ),
          ),

          if (provider.isProcessingAI) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 8),
                  Text('Checking Number Rule & Formulating Response...', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],

          // Input Bar with Mic & Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Voice Recording Button
                  InkWell(
                    onTap: () {
                      provider.toggleVoiceRecording();
                      if (provider.isVoiceRecording) {
                        // Simulate voice query after 2 seconds
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted && provider.isVoiceRecording) {
                            provider.toggleVoiceRecording();
                            provider.sendChatMessage('आमच्या गावात कोणता व्यवसाय करावा?');
                            _scrollToBottom();
                          }
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: provider.isVoiceRecording ? AppColors.secondaryOrange : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        provider.isVoiceRecording ? Icons.mic : Icons.mic_none,
                        color: provider.isVoiceRecording ? Colors.white : AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: provider.langCode == 'mr'
                            ? 'प्रश्न विचारा किंवा टाइप करा...'
                            : 'Ask a question or type here...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (text) {
                        provider.sendChatMessage(text);
                        _textController.clear();
                        _scrollToBottom();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Button
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: () {
                      provider.sendChatMessage(_textController.text);
                      _textController.clear();
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, AppStateProvider provider, ChatMessage msg) {
    bool isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                      bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                    border: Border.all(color: isUser ? Colors.transparent : AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isUser ? Colors.white : AppColors.textMain,
                          height: 1.4,
                        ),
                      ),
                      if (!isUser && msg.hasNumber) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 8),

                        // Provenance & Number Rule Verification Card
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified, color: AppColors.usefulGreen, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Number Rule Verified (Rule 11)',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.usefulGreen),
                                  ),
                                  const Spacer(),
                                  Text(
                                    msg.sourceDate ?? 'Estimate',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              if (msg.sourceCitation != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  'Source: ${msg.sourceCitation}',
                                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                                ),
                              ],
                              if (msg.calculatedFormula != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Math: ${msg.calculatedFormula}',
                                  style: const TextStyle(fontSize: 10, color: AppColors.primary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Actionable Tips & TTS Playback Controls
          if (!isUser && msg.actionableTips.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...msg.actionableTips.map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.secondaryOrange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textMain),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => provider.toggleAudioPlayback(msg.id),
                        icon: Icon(
                          msg.isAudioPlaying ? Icons.stop_circle : Icons.volume_up,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          msg.isAudioPlaying ? 'Stop Audio' : 'Listen in Marathi / ऐका',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showNumberRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Strict Number Rule (Section 11)'),
        content: const SingleChildScrollView(
          child: Text(
            'We do not rely on "AI feeling sure" because AI can be sure and wrong.\n\n'
            'A number is shown only if it:\n'
            '1. Comes from an approved source or expert crop table.\n'
            '2. Is recent, within verified limits.\n'
            '3. Retains source citation link.\n'
            '4. Mathematical calculations performed by deterministic code.\n'
            '5. Expressed as a range when sources differ.\n'
            '6. Labelled Estimate with date.\n\n'
            'If any test fails, VanRozgar politely refers you to Krishi Vigyan Kendra (KVK).',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
