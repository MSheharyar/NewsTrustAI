import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _isTyping = false;

  final List<_ChatMsg> _messages = [
    _ChatMsg.bot(
      "Hi! I’m NewsTrust AI Bot 🤖\n\n"
      "You can:\n"
      "• Ask how the app works\n"
      "• Paste a news claim to verify\n"
      "• Paste a link and I’ll guide you\n\n"
      "Try: “Verify this news” or paste a headline.",
    ),
  ];

  final List<_QuickChip> _chips = const [
    _QuickChip("Verify News", "verify news"),
    _QuickChip("Verify Link", "verify link"),
    _QuickChip("Trending", "trending"),
    _QuickChip("Help", "help"),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool _looksLikeUrl(String s) {
    final t = s.trim().toLowerCase();
    return t.startsWith("http://") || t.startsWith("https://") || t.startsWith("www.");
  }

  Future<void> _send(String text) async {
    final msg = text.trim();
    if (msg.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg.user(msg));
      _controller.clear();
    });
    _scrollToBottom();

    await _botReply(msg);
  }

  Future<void> _botReply(String userText) async {
    setState(() => _isTyping = true);
    _scrollToBottom();

    final lower = userText.toLowerCase().trim();

    // --- URL guidance ---
    if (_looksLikeUrl(userText)) {
      setState(() {
        _messages.add(_ChatMsg.bot(
          "That looks like a link 🔗\n\n"
          "Go to **Link Verification** screen and paste it there.\n"
          "If you want, I can also verify the extracted text if the site allows reading.",
        ));
        _isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    // --- simple intent matching ---
    if (lower.contains("help") || lower.contains("how")) {
      setState(() {
        _messages.add(_ChatMsg.bot(
          "Here’s what I can do:\n\n"
          "1) **Verify a claim**: paste a headline/claim → I’ll offer verification.\n"
          "2) **Guide you**: explain Verified / Fake / Unverified.\n"
          "3) **Direct you**: if you paste a link, I’ll tell you to use Link Verification.\n\n"
          "Paste a headline now 👇",
        ));
        _isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    if (lower.contains("verified") || lower.contains("unverified") || lower.contains("fake")) {
      setState(() {
        _messages.add(_ChatMsg.bot(
          "Meaning of results:\n\n"
          "✅ **Verified (Real)**: matched with trusted sources / strong evidence.\n"
          "⚠️ **Unverified**: not enough evidence found.\n"
          "❌ **Fake**: model/evidence suggests it’s false or misleading.\n\n"
          "If you paste a claim, I can verify it.",
        ));
        _isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    // --- If user asks “verify” explicitly OR message is long enough, offer verify action ---
    final shouldOfferVerify =
        lower.contains("verify") || userText.trim().split(RegExp(r"\s+")).length >= 6;

    if (shouldOfferVerify) {
      setState(() {
        _messages.add(_ChatMsg.botWithAction(
          "I can verify this claim:\n\n“$userText”\n\nTap **Verify Now** to check.",
          actionLabel: "Verify Now",
          actionPayload: userText,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    // --- fallback small talk style ---
    setState(() {
      _messages.add(_ChatMsg.bot(
        "Got it ✅\n\nIf you want verification, paste the full headline/claim "
        "or type **verify** and I’ll check it.",
      ));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  Future<void> _verifyClaim(String claim) async {
    setState(() => _isTyping = true);
    _scrollToBottom();

    final res = await ApiService.verifyText(claim);

    if (!mounted) return;
    setState(() => _isTyping = false);

    if (res["error"] == true) {
      setState(() {
        _messages.add(_ChatMsg.bot("❌ Couldn’t verify right now:\n${res["message"] ?? "Unknown error"}"));
      });
      _scrollToBottom();
      return;
    }

    final label = (res["final_label"] ?? res["authenticity"] ?? "unverified").toString();
    final conf = (res["final_confidence"] ?? res["confidence"]);
    final reason = (res["final_reason"] ?? "Analysis completed.").toString();

    String emoji;
    if (label == "real") {
      emoji = "✅";
    } else if (label == "fake") {
      emoji = "❌";
    } else {
      emoji = "⚠️";
    }

    final confText = conf == null ? "N/A" : "${conf.toString()}%";

    setState(() {
      _messages.add(_ChatMsg.bot(
        "$emoji Result: **${label.toUpperCase()}**\n"
        "Confidence: $confText\n\n"
        "Reason: $reason",
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Bot"),        
      ),
      body: Column(
        children: [
          // Quick chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final c = _chips[i];
                return ActionChip(
                  label: Text(c.title),
                  onPressed: () => _send(c.payload),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: _chips.length,
            ),
          ),

          const Divider(height: 1),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return _TypingBubble();
                }
                final m = _messages[i];
                return _ChatBubble(
                  msg: m,
                  onActionTap: (payload) => _verifyClaim(payload),
                );
              },
            ),
          ),

          // Input
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Type a message or paste a headline…",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(LucideIcons.send),
                    onPressed: () => _send(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip {
  final String title;
  final String payload;
  const _QuickChip(this.title, this.payload);
}

class _ChatMsg {
  final bool isUser;
  final String text;

  final String? actionLabel;
  final String? actionPayload;

  const _ChatMsg._(
    this.isUser,
    this.text, {
    this.actionLabel,
    this.actionPayload,
  });

  factory _ChatMsg.user(String t) => _ChatMsg._(true, t);
  factory _ChatMsg.bot(String t) => _ChatMsg._(false, t);

  factory _ChatMsg.botWithAction(
    String t, {
    required String actionLabel,
    required String actionPayload,
  }) =>
      _ChatMsg._(
        false,
        t,
        actionLabel: actionLabel,
        actionPayload: actionPayload,
      );
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  final void Function(String payload) onActionTap;

  const _ChatBubble({required this.msg, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
                height: 1.3,
              ),
            ),
            if (!isUser && msg.actionLabel != null && msg.actionPayload != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => onActionTap(msg.actionPayload!),
                  child: Text(msg.actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("Typing…"),
      ),
    );
  }
}