import 'package:flutter/material.dart';
import 'dart:math';
import '../info_screen.dart';
import 'package:confetti/confetti.dart';

class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({super.key});

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  late ConfettiController _confettiController;
  List<VocabItem> _gameSentences = [];
  int _currentIndex = 0;
  int _score = 0;
  
  List<String> _shuffledWords = [];
  List<String> _userSentence = [];
  List<bool> _isWordUsed = [];
  
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _startGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _cleanPunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  void _startGame() {
    final random = Random();
    // Filter items that actually have an example sentence
    var allItems = allCategories
        .expand((c) => c.items)
        .where((item) => item.exampleSentence.isNotEmpty && item.engExample.isNotEmpty)
        .toList();
    
    allItems.shuffle(random);
    _gameSentences = allItems.take(5).toList(); // 5 sentences per game
    
    _currentIndex = 0;
    _score = 0;
    _isGameOver = false;
    _loadCurrentSentence();
  }

  void _loadCurrentSentence() {
    if (_currentIndex >= _gameSentences.length) {
      setState(() {
        _isGameOver = true;
      });
      _confettiController.play();
      return;
    }

    final rawSentence = _gameSentences[_currentIndex].exampleSentence;
    final cleanSentence = _cleanPunctuation(rawSentence);
    
    _shuffledWords = cleanSentence.split(' ')..removeWhere((w) => w.isEmpty);
    _shuffledWords.shuffle(Random());
    
    _userSentence = List.filled(_shuffledWords.length, '');
    _isWordUsed = List.filled(_shuffledWords.length, false);
    setState(() {});
  }

  void _onWordTap(String word, int index) {
    if (_isWordUsed[index]) return;
    int emptyIndex = _userSentence.indexOf('');
    if (emptyIndex != -1) {
      setState(() {
        _userSentence[emptyIndex] = word;
        _isWordUsed[index] = true;
      });
      _checkAnswer();
    }
  }

  void _onAnswerTap(String word, int index) {
    if (word.isNotEmpty) {
      int originalIndex = -1;
      for (int i = 0; i < _shuffledWords.length; i++) {
        if (_shuffledWords[i] == word && _isWordUsed[i]) {
          originalIndex = i;
          break;
        }
      }
      if (originalIndex != -1) {
        setState(() {
          _isWordUsed[originalIndex] = false;
          _userSentence[index] = '';
        });
      }
    }
  }

  void _checkAnswer() {
    if (!_userSentence.contains('')) {
      final correctSentence = _cleanPunctuation(_gameSentences[_currentIndex].exampleSentence).toLowerCase();
      final userBuilt = _userSentence.join(' ').toLowerCase();
      
      if (userBuilt == correctSentence) {
        setState(() {
          _score += 20; // 20 pts per sentence
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bagus! Correct sentence!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          _currentIndex++;
          _loadCurrentSentence();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Grammar check failed. Try rearranging!'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_rounded, color: Colors.blueAccent, size: 100),
                  const SizedBox(height: 24),
                  const Text('Grammar Master!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Final Score: $_score / 100', style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C6BC0),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      setState(() {
                        _startGame();
                      });
                    },
                    child: const Text('Play Again', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Home', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
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

    if (_gameSentences.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentVocab = _gameSentences[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text('Sentence Builder (${_currentIndex + 1}/${_gameSentences.length})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Translation Clue
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5C6BC0).withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.translate_rounded, color: Colors.white54, size: 30),
                  const SizedBox(height: 12),
                  const Text('Translate to BM:', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    currentVocab.engExample,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Build Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12, style: BorderStyle.solid),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_userSentence.length, (index) {
                    final word = _userSentence[index];
                    return GestureDetector(
                      onTap: () => _onAnswerTap(word, index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: word.isEmpty ? Colors.white10 : const Color(0xFF5C6BC0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          word.isEmpty ? '     ' : word,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Word Bank
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Text('Word Bank', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(_shuffledWords.length, (index) {
                      final word = _shuffledWords[index];
                      final isUsed = _isWordUsed[index];
                      return GestureDetector(
                        onTap: isUsed ? null : () => _onWordTap(word, index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUsed ? Colors.transparent : const Color(0xFF2C3242),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isUsed ? Colors.white10 : Colors.white24),
                            boxShadow: isUsed ? [] : [
                              const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                            ],
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              color: isUsed ? Colors.transparent : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _loadCurrentSentence(); 
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
                    label: const Text('Reset', style: TextStyle(color: Colors.white54)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
