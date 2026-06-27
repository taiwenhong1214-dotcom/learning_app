import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/firebase_service.dart';

// ─────────────────────────────────────────────────────
//  AI Screen — Tab 1: Conversation · Tab 2: Quiz
// ─────────────────────────────────────────────────────
class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD54F),
          indicatorWeight: 3,
          labelColor: const Color(0xFFFFD54F),
          unselectedLabelColor: const Color(0xFF8B949E),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_rounded), text: 'Conversation'),
            Tab(icon: Icon(Icons.quiz_rounded), text: 'AI Quiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ConversationTab(),
          _AiQuizTab(),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
//  TAB 1 — AI CONVERSATION PRACTICE
// ═════════════════════════════════════════════════════
class _ConversationTab extends StatefulWidget {
  const _ConversationTab();

  @override
  State<_ConversationTab> createState() => _ConversationTabState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  _ChatMessage({required this.text, required this.isUser, DateTime? time})
      : time = time ?? DateTime.now();
}

class _ConversationTabState extends State<_ConversationTab> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  // Models to try in order (fallback chain)
  static const List<String> _models = [
    'nvidia/nemotron-3-ultra-550b-a55b:free',
    'openai/gpt-oss-120b:free',
    'deepseek/deepseek-v4-flash',
  ];

  static const String _systemPrompt =
      'You are a Bahasa Malaysia tutor. The user is a beginner learning BM. '
      'Reply in simple Bahasa Malaysia, gently correct any grammar mistakes, '
      'and encourage them. Keep replies short.';

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(_ChatMessage(
      text: 'Selamat datang! 👋 Saya tutor Bahasa Malaysia anda. Cuba tulis sesuatu dalam BM!',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Build the messages list for the API (with system prompt)
  List<Map<String, String>> _buildApiMessages() {
    final apiMessages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
    ];
    // Include last 20 messages for context
    final recent = _messages.length > 20
        ? _messages.sublist(_messages.length - 20)
        : _messages;
    for (final msg in recent) {
      apiMessages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }
    return apiMessages;
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _msgController.clear();
    _scrollToBottom();

    // Add a placeholder for AI response (streaming)
    final aiMessage = _ChatMessage(text: '', isUser: false);
    setState(() => _messages.add(aiMessage));
    _scrollToBottom();

    try {
      await _callOpenRouterStreaming(aiMessage);
    } catch (e) {
      setState(() {
        _messages.remove(aiMessage);
        _messages.add(_ChatMessage(
          text: 'Maaf, ada masalah teknikal. Sila cuba lagi. 😔\n\nError: $e',
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> _callOpenRouterStreaming(_ChatMessage aiMessage) async {
    final apiMessages = _buildApiMessages();
    // Remove the empty AI placeholder from API messages
    if (apiMessages.isNotEmpty && apiMessages.last['role'] == 'assistant' && apiMessages.last['content']!.isEmpty) {
      apiMessages.removeLast();
    }

    final request = http.Request(
      'POST',
      Uri.parse('https://bm-learning-app.vercel.app/api/chat'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
    });
    request.body = jsonEncode({
      'models': _models,
      'messages': apiMessages,
      'temperature': 0.7,
      'stream': true,
    });

    final client = http.Client();
    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw Exception('API error ${response.statusCode}: $body');
      }

      // Parse SSE stream
      final buffer = StringBuffer();
      await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data == '[DONE]') continue;
          try {
            final json = jsonDecode(data);
            
            // Check for OpenRouter API error mid-stream
            if (json.containsKey('error')) {
              final errMsg = json['error']?['message'] ?? 'Unknown Error';
              buffer.write('\n\n[API Error: $errMsg]');
            } else {
              final content = json['choices']?[0]?['delta']?['content'] ?? '';
              if (content.isNotEmpty) {
                buffer.write(content);
              }
            }
            
            if (buffer.isNotEmpty) {
              setState(() {
                // The AI message is always the last one since the user can't send messages while streaming
                if (_messages.isNotEmpty && !_messages.last.isUser) {
                  _messages[_messages.length - 1] = _ChatMessage(
                    text: buffer.toString(),
                    isUser: false,
                    time: _messages.last.time,
                  );
                }
              });
              _scrollToBottom();
            }
          } catch (_) {
            // Skip malformed JSON chunks
          }
        }
      }

      // If no content received, show a fallback message
      if (buffer.isEmpty) {
        setState(() {
          final idx = _messages.indexOf(aiMessage);
          if (idx != -1) {
            _messages[idx] = _ChatMessage(
              text: 'Maaf, saya tidak dapat membalas sekarang. Cuba lagi!',
              isUser: false,
              time: aiMessage.time,
            );
          }
        });
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemCount: _messages.length + (_isLoading && _messages.last.text.isEmpty ? 0 : 0),
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return _ChatBubble(message: msg);
            },
          ),
        ),

        // Typing indicator
        if (_isLoading && _messages.isNotEmpty && _messages.last.text.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFD54F),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'AI sedang menaip...',
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                ),
              ],
            ),
          ),

        // Input bar
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Tulis mesej dalam BM...',
                      hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                      filled: true,
                      fillColor: const Color(0xFF1C2333),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Chat bubble widget
class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeStr =
        '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF5C6BC0),
              child: const Icon(Icons.smart_toy_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1C2333), Color(0xFF1C2333)],
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text.isEmpty ? '...' : message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFFE6EDF3),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.6)
                          : const Color(0xFF8B949E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
//  TAB 2 — AI QUIZ GENERATOR
// ═════════════════════════════════════════════════════
class _AiQuizTab extends StatefulWidget {
  const _AiQuizTab();

  @override
  State<_AiQuizTab> createState() => _AiQuizTabState();
}

enum QuizState { setup, loading, playing, finished }

class _QuizQuestion {
  final String question;
  final List<String> options;
  final int answer;
  _QuizQuestion({required this.question, required this.options, required this.answer});

  factory _QuizQuestion.fromJson(Map<String, dynamic> json) {
    return _QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? 0,
    );
  }
}

class _AiQuizTabState extends State<_AiQuizTab> {
  String _difficulty = 'Easy';
  QuizState _quizState = QuizState.setup;
  List<_QuizQuestion> _questions = [];
  int _currentQ = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;

  static const List<String> _models = [
    'nvidia/nemotron-3-ultra-550b-a55b:free',
    'openai/gpt-oss-120b:free',
    'deepseek/deepseek-v4-flash',
  ];

  Future<void> _generateQuiz() async {
    setState(() => _quizState = QuizState.loading);

    final prompt =
        'Generate 5 Bahasa Malaysia vocabulary multiple choice questions at $_difficulty level. '
        'Each question shows an English word and 4 BM options. '
        'Return ONLY a valid JSON array with fields: question, options (array of 4 strings), answer (index 0-3). '
        'No markdown, no explanation, just the JSON array.';

    try {
      final response = await http.post(
        Uri.parse('https://bm-learning-app.vercel.app/api/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'models': _models,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.8,
          'stream': false,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }

      final json = jsonDecode(response.body);
      final content = json['choices'][0]['message']['content'] as String;

      // Extract JSON array from response (handle markdown code blocks)
      String jsonStr = content.trim();
      // Remove thinking tags if present
      jsonStr = jsonStr.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '').trim();
      if (jsonStr.contains('```')) {
        final match = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(jsonStr);
        if (match != null) jsonStr = match.group(1)!.trim();
      }

      final List<dynamic> questionsJson = jsonDecode(jsonStr);
      _questions = questionsJson.map((q) => _QuizQuestion.fromJson(q)).toList();
      _currentQ = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
      setState(() => _quizState = QuizState.playing);
    } catch (e) {
      setState(() => _quizState = QuizState.setup);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate quiz: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentQ].answer) {
        _score++;
      }
    });
  }

  void _nextQuestion() async {
    if (_currentQ < _questions.length - 1) {
      setState(() {
        _currentQ++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      // Save score to Firebase, but don't block the UI if it fails
      if (_score > 0) {
        try {
          await FirebaseService.saveQuizScore(_score);
        } catch (e) {
          print("Failed to save score to Firebase: $e");
        }
      }
      if (mounted) {
        setState(() => _quizState = QuizState.finished);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_quizState) {
      case QuizState.setup:
        return _buildSetup();
      case QuizState.loading:
        return _buildLoading();
      case QuizState.playing:
        return _buildQuestion();
      case QuizState.finished:
        return _buildResult();
    }
  }

  Widget _buildSetup() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.psychology_rounded, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI Quiz Generator',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your Bahasa Malaysia vocabulary!',
              style: TextStyle(color: Color(0xFF8B949E), fontSize: 15),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Difficulty',
              style: TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Easy', 'Medium', 'Hard'].map((d) {
                final isSelected = _difficulty == d;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(d),
                    selected: isSelected,
                    selectedColor: const Color(0xFF5C6BC0),
                    backgroundColor: const Color(0xFF1C2333),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF8B949E),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF5C6BC0) : const Color(0xFF30363D),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _difficulty = d);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: _generateQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox(width: 8),
                    Text('Generate Quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: Color(0xFFFFD54F),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'AI is creating your quiz...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(color: Color(0xFF8B949E), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_currentQ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                'Question ${_currentQ + 1}/${_questions.length}',
                style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                'Score: $_score',
                style: const TextStyle(color: Color(0xFF8B949E)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQ + 1) / _questions.length,
              backgroundColor: const Color(0xFF1C2333),
              color: const Color(0xFF5C6BC0),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 24),

          // Question card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2333),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Text(
              q.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Options
          ...List.generate(q.options.length, (i) {
            final isSelected = _selectedAnswer == i;
            final isCorrect = i == q.answer;
            Color bgColor = const Color(0xFF1C2333);
            Color borderColor = const Color(0xFF30363D);
            IconData? icon;

            if (_answered) {
              if (isCorrect) {
                bgColor = Colors.green.shade900.withValues(alpha: 0.3);
                borderColor = Colors.green;
                icon = Icons.check_circle_rounded;
              } else if (isSelected && !isCorrect) {
                bgColor = Colors.red.shade900.withValues(alpha: 0.3);
                borderColor = Colors.red;
                icon = Icons.cancel_rounded;
              }
            } else if (isSelected) {
              borderColor = const Color(0xFF5C6BC0);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _selectAnswer(i),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected && !_answered
                              ? const Color(0xFF5C6BC0)
                              : const Color(0xFF30363D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + i), // A, B, C, D
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.options[i],
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      if (icon != null)
                        Icon(icon, color: isCorrect ? Colors.green : Colors.red, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),

          if (_answered) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6BC0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _currentQ < _questions.length - 1 ? 'Next Question →' : 'See Results',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult() {
    final percentage = (_score / _questions.length * 100).round();
    String emoji;
    String message;
    if (percentage >= 80) {
      emoji = '🎉';
      message = 'Hebat! (Excellent!)';
    } else if (percentage >= 60) {
      emoji = '👍';
      message = 'Bagus! (Good job!)';
    } else {
      emoji = '💪';
      message = 'Teruskan usaha! (Keep trying!)';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Column(
                children: [
                  const Text('Your Score', style: TextStyle(color: Color(0xFF8B949E), fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '$_score / ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD54F),
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(color: Color(0xFF8B949E), fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _quizState = QuizState.setup;
                    _questions = [];
                    _currentQ = 0;
                    _score = 0;
                    _selectedAnswer = null;
                    _answered = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded),
                    SizedBox(width: 8),
                    Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
