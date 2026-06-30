import 'package:flutter/material.dart';
import 'dart:math';
import 'info_screen.dart';
import 'package:confetti/confetti.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
 
  List<String> _getRandomWrongOptions(List<VocabItem> allItems, VocabItem correctItem, String Function(VocabItem) selector, int count) {
    final random = Random();
    final otherItems = allItems.where((i) => selector(i).toLowerCase() != selector(correctItem).toLowerCase()).toList();
    // To ensure completely unique wrong options
    final uniqueOtherItems = otherItems.map((i) => selector(i)).toSet().toList();
    uniqueOtherItems.shuffle(random);
    return uniqueOtherItems.take(count).toList();
  }

  List<Map<String, Object>> _quizQuestions = [];
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  bool _isQuizStarted = false;

  void _startQuiz() {
    List<Map<String, Object>> generatedQuestions = [];
    final allItems = allCategories.expand((c) => c.items).toList();
    final random = Random();

    allItems.shuffle(random);
    final selectedItems = allItems.take(10).toList();

    for (var item in selectedItems) {
      final questionType = random.nextInt(3); 
      
      String questionText;
      String correctOption;
      List<String> wrongOptions = [];
      
      if (questionType == 0) {
        questionText = 'What does "${item.bmWord}" mean in English?';
        correctOption = item.engMeaning;
        wrongOptions = _getRandomWrongOptions(allItems, item, (i) => i.engMeaning, 3);
      } else if (questionType == 1) {
        questionText = 'How do you say "${item.engMeaning}" in BM?';
        correctOption = item.bmWord;
        wrongOptions = _getRandomWrongOptions(allItems, item, (i) => i.bmWord, 3);
      } else {
        if (item.exampleSentence.toLowerCase().contains(item.bmWord.toLowerCase())) {
          String blankedSentence = item.exampleSentence.replaceAll(RegExp(item.bmWord, caseSensitive: false), '____');
          questionText = 'Fill in the blank:\n"$blankedSentence"\n(${item.engExample})';
          correctOption = item.bmWord;
          wrongOptions = _getRandomWrongOptions(allItems, item, (i) => i.bmWord, 3);
        } else {
          questionText = 'Which category does "${item.bmWord}" belong to?';
          correctOption = item.category;
          wrongOptions = _getRandomWrongOptions(allItems, item, (i) => i.category, 3);
        }
      }
      
      List<String> options = [correctOption, ...wrongOptions];
      options.shuffle(random);
      int correctIndex = options.indexOf(correctOption);
      
      generatedQuestions.add({
        'question': questionText,
        'answers': options,
        'correctIndex': correctIndex,
      });
    }

    setState(() {
      _quizQuestions = generatedQuestions;
      _questionIndex = 0;
      _score = 0;
      _isQuizStarted = true;
      _hasAnswered = false;
      _selectedAnswerIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (!_isQuizStarted) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1D26), Color(0xFF252A36)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.quiz_rounded, size: 100, color: Colors.indigoAccent),
                ),
                const SizedBox(height: 30),
                const Text("Ready to Test Your BM?", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("10 Questions • Vocabulary", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _startQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 8,
                    shadowColor: Colors.indigoAccent.withOpacity(0.5),
                  ),
                  child: const Text("Start Quiz", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questionIndex >= _quizQuestions.length) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1D26), Color(0xFF252A36)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _score > 5 ? Icons.emoji_events_rounded : Icons.star_half_rounded,
                  size: 100,
                  color: _score > 5 ? Colors.amber : Colors.orangeAccent,
                ),
                const SizedBox(height: 20),
                const Text('Quiz Completed!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('You scored', style: TextStyle(color: Colors.white70, fontSize: 20)),
                const SizedBox(height: 10),
                Text('$_score / ${_quizQuestions.length}', style: const TextStyle(color: Colors.indigoAccent, fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isQuizStarted = false),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Play Again", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // points straight down
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
          ),
        ),
      ],
    ),
  );
}

    final q = _quizQuestions[_questionIndex];
    final answers = q['answers'] as List<String>;
    final correctIndex = q['correctIndex'] as int;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Question ${_questionIndex + 1} of ${_quizQuestions.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1D26), Color(0xFF252A36)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_questionIndex + 1) / _quizQuestions.length,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3242),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8)),
                            ],
                          ),
                          child: Text(
                            q['question'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...answers.asMap().entries.map((e) {
                          bool isSelected = (_selectedAnswerIndex == e.key);
                          bool isCorrect = (e.key == correctIndex);
                          Color bgColor = const Color(0xFF2C3242);
                          Color borderColor = Colors.transparent;
                          IconData? iconData;

                          if (_hasAnswered) {
                            if (isCorrect) { 
                              bgColor = Colors.green.withOpacity(0.2); 
                              borderColor = Colors.green; 
                              iconData = Icons.check_circle_rounded;
                            } else if (isSelected) { 
                              bgColor = Colors.red.withOpacity(0.2); 
                              borderColor = Colors.red; 
                              iconData = Icons.cancel_rounded;
                            }
                          } else if (isSelected) {
                            borderColor = Colors.indigoAccent;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: _hasAnswered ? null : () => setState(() {
                                _selectedAnswerIndex = e.key;
                                _hasAnswered = true;
                                if (isCorrect) _score++;
                              }),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: bgColor, 
                                  border: Border.all(color: borderColor, width: 2), 
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _hasAnswered && isCorrect ? Colors.green : (_hasAnswered && isSelected ? Colors.red : Colors.white12),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text("${String.fromCharCode(65 + e.key)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 16))),
                                    if (_hasAnswered && iconData != null) Icon(iconData, color: borderColor, size: 28),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_hasAnswered)
                          const SizedBox(height: 12),
                        if (_hasAnswered)
                          AnimatedOpacity(
                            opacity: _hasAnswered ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigoAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  setState(() { 
                                    _questionIndex++; 
                                    _hasAnswered = false; 
                                    _selectedAnswerIndex = null; 
                                    if (_questionIndex >= _quizQuestions.length) {
                                      _confettiController.play();
                                    }
                                  });
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Next Question", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}