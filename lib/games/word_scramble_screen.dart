import 'package:flutter/material.dart';
import 'dart:math';
import '../info_screen.dart';
import 'package:confetti/confetti.dart';

//Since game state (score, current question number, letters entered) 
//is constantly changing, the page needs to refresh continuously.
class WordScrambleScreen extends StatefulWidget {
  const WordScrambleScreen({super.key});

  @override
  State<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {
  late ConfettiController _confettiController;
  List<VocabItem> _gameWords = [];
  int _currentIndex = 0;
  int _score = 0;
  
  List<String> _shuffledLetters = [];
  List<String> _userAnswer = [];
  
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

  void _startGame() {
    final random = Random();
    // Filter out words with spaces or hyphens for spelling simplicity
    var allItems = allCategories
        .expand((c) => c.items)
        .where((item) => !item.bmWord.contains(' ') && !item.bmWord.contains('-'))
        .toList();
    
    allItems.shuffle(random);
    _gameWords = allItems.take(10).toList();
    
    _currentIndex = 0;
    _score = 0;
    _isGameOver = false;
    _loadCurrentWord();
  }

  void _loadCurrentWord() {
    //Pre-check: Have you finished all the questions? 
    //Congratulations! Change the status to "Game Over," 
    //then press the remote control to spray confetti!
    if (_currentIndex >= _gameWords.length) {
      setState(() {
        _isGameOver = true;
      });
      _confettiController.play();
      return;
    }

    final currentWord = _gameWords[_currentIndex].bmWord.toUpperCase();
    _shuffledLetters = currentWord.split('');
    _shuffledLetters.shuffle(Random());
    
    // Ensure it's actually shuffled
    if (_shuffledLetters.join() == currentWord && currentWord.length > 2) {
      _shuffledLetters.shuffle(Random());
    }
    
    _userAnswer = List.filled(currentWord.length, '');
    setState(() {});
  }

  void _onLetterTap(String letter, int index) {
    // Find first empty slot in user answer
    int emptyIndex = _userAnswer.indexOf('');
    if (emptyIndex != -1) {
      setState(() {
        _userAnswer[emptyIndex] = letter;
        _shuffledLetters[index] = ''; // Remove from available
      });
      _checkAnswer();
    }
  }

  void _onAnswerTap(String letter, int index) {
    if (letter.isNotEmpty) {
      // Find first empty slot in shuffled letters
      int emptyIndex = _shuffledLetters.indexOf('');
      if (emptyIndex != -1) {
        setState(() {
          _shuffledLetters[emptyIndex] = letter;
          _userAnswer[index] = '';
        });
      }
    }
  }

  void _checkAnswer() {
    if (!_userAnswer.contains('')) {
      final currentWord = _gameWords[_currentIndex].bmWord.toUpperCase();
      if (_userAnswer.join() == currentWord) {
        // Correct!
        setState(() {
          _score += 10;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Correct! Great job! 🎉', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        
        // Show success briefly before moving on
        Future.delayed(const Duration(milliseconds: 1500), () {
          _currentIndex++;
          _loadCurrentWord();
        });
      } else {
        // Wrong answer, shake or just highlight red (simplified to just clearing here or letting user undo)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not quite right! Try again.'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) {
      return _buildGameOver();
    }

    if (_gameWords.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentVocab = _gameWords[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text('Spelling Bee (${_currentIndex + 1}/${_gameWords.length})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text('Score: $_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // English Clue
              Container(
                width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5C6BC0).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Text('Spell the BM word for:', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    currentVocab.engMeaning,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // User Answer Slots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(_userAnswer.length, (index) {
                  final letter = _userAnswer[index];
                  // Calculate width to fit all letters in one row if possible
                  double screenWidth = MediaQuery.of(context).size.width;
                  double boxWidth = (screenWidth - 32 - (_userAnswer.length - 1) * 6) / _userAnswer.length;
                  if (boxWidth > 50) boxWidth = 50; // Cap max width
                  
                  return GestureDetector(
                    onTap: () => _onAnswerTap(letter, index),
                    child: Container(
                      width: boxWidth,
                      height: boxWidth > 40 ? 60 : boxWidth * 1.4,
                      decoration: BoxDecoration(
                        color: letter.isEmpty ? Colors.white10 : const Color(0xFF5C6BC0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: letter.isEmpty ? Colors.white24 : Colors.transparent),
                        boxShadow: letter.isEmpty ? [] : [
                          BoxShadow(color: const Color(0xFF5C6BC0).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: boxWidth > 40 ? 24 : 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Available Letters
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Text('Tap letters to spell', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(_shuffledLetters.length, (index) {
                      final letter = _shuffledLetters[index];
                      // Calculate width to fit all available letters in one row if possible
                      double screenWidth = MediaQuery.of(context).size.width;
                      double boxWidth = (screenWidth - 48 - (_shuffledLetters.length - 1) * 8) / _shuffledLetters.length;
                      if (boxWidth > 50) boxWidth = 50;

                      return GestureDetector(
                        onTap: letter.isEmpty ? null : () => _onLetterTap(letter, index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: boxWidth,
                          height: boxWidth > 40 ? 50 : boxWidth * 1.2,
                          decoration: BoxDecoration(
                            color: letter.isEmpty ? Colors.transparent : const Color(0xFF2C3242),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: letter.isEmpty ? Colors.white10 : Colors.white24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: letter.isEmpty ? Colors.transparent : Colors.white,
                              fontSize: boxWidth > 40 ? 22 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _loadCurrentWord(); // Reset current word
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
                    label: const Text('Reset Word', style: TextStyle(color: Colors.white54)),
                  )
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 100),
                const SizedBox(height: 24),
                const Text('Spelling Bee Completed!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Final Score: $_score', style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
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
}
