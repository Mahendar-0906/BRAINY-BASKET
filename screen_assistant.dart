import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key, required this.state});
  final AppState state;
  @override State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [
    _Message("Hi! I'm your Brainy Basket kitchen assistant 🧑‍🍳\n\nI know what's in your pantry. Ask me what you can cook, what's running low, or what to buy!", isBot: true),
  ];

  static const _suggestions = [
    'What can I cook today?',
    'What ingredients do I have?',
    'What should I buy?',
    'Suggest dinner',
    'What is running low?',
    'Give me a recipe using tomatoes',
    'What can I make with rice and eggs?',
  ];

  @override
  void dispose() { _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            color: kBg,
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: kBlueLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome, color: kBlue, size: 20)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xff173e37))),
                Text('Powered by your pantry data', style: TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 8, color: kGreen), SizedBox(width: 4), Text('Online', style: TextStyle(fontSize: 11, color: kGreen, fontWeight: FontWeight.w700))])),
            ]),
          ),
          const Divider(height: 1),
          // Messages
          Expanded(child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _buildMessage(_messages[i]),
          )),
          // Suggestions
          if (_messages.length <= 2) Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: _suggestions.map((s) => GestureDetector(
              onTap: () => _send(s),
              child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xffe0e0e0))), child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff7a8a85)))),
            )).toList()),
          ),
          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: kBg,
            child: Row(children: [
              Expanded(child: TextField(
                controller: _controller,
                onSubmitted: (_) => _send(_controller.text),
                decoration: InputDecoration(
                  hintText: 'Ask your kitchen assistant...',
                  filled: true, fillColor: kCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_controller.text),
                child: Container(width: 46, height: 46, decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(23)), child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
              ),
            ]),
          ),
        ])),
      );

  Widget _buildMessage(_Message msg) => Align(
        alignment: msg.isBot ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            color: msg.isBot ? kCard : kGreen,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(msg.isBot ? 4 : 18),
              bottomRight: Radius.circular(msg.isBot ? 18 : 4),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Text(msg.text, style: TextStyle(color: msg.isBot ? Colors.black87 : Colors.white, height: 1.4)),
        ),
      );

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(text.trim(), isBot: false));
      _messages.add(_Message(widget.state.ask(text.trim()), isBot: true));
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }
}

class _Message {
  const _Message(this.text, {required this.isBot});
  final String text;
  final bool isBot;
}
