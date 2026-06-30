import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'info_screen.dart';

import 'dart:math';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToLearn;
  final VoidCallback? onNavigateToQuiz;

  const HomeScreen({super.key, this.onNavigateToLearn, this.onNavigateToQuiz});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VocabItem dailyWord;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final randomCategory = allCategories[random.nextInt(allCategories.length)];
    dailyWord = randomCategory.items[random.nextInt(randomCategory.items.length)];
  }

  void _navigateToCategory(VocabCategory category) {
    if (widget.onNavigateToLearn != null) {
      widget.onNavigateToLearn!();
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A4A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1C2333),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(color: Color(0xFFE6EDF3)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B949E))),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseService.signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //the main header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1B2A4A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //display greeting and app name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Hey there welcome to the app',
                              style: TextStyle(
                                color: Color(0xFFC8B89A),
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'LearnBM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      //create badge container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8B89A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'English to BM',
                          style: TextStyle(
                            color: Color(0xFF1B2A4A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  //the welcome banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF243860),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jom belajar',
                                style: TextStyle(
                                  color: Color(0xFFC8B89A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Start your Bahasa Melayu Language Journey today',
                                style: TextStyle(
                                  color: Color(0xFFF5F0E8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          '🧾',
                          style: TextStyle(fontSize: 40),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),

            //fast Access Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Fast Access',
                    style: TextStyle(
                      color: Color(0xFF1B2A4A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  //learning categories
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [

                      //family notes
                      GestureDetector(
                        onTap: () {
                          final category = allCategories.firstWhere((c) => c.name == 'Keluarga');
                          _navigateToCategory(category);
                        },
                        child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A4A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 26)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Keluarga',
                                  style: TextStyle(
                                    color: Color(0xFFF5F0E8),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Family',
                                  style: TextStyle(
                                    color: Color(0xFFC8B89A),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ),

                      //vehicles notes
                      GestureDetector(
                        onTap: () {
                          final category = allCategories.firstWhere((c) => c.name == 'Kenderaan');
                          _navigateToCategory(category);
                        },
                        child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4C9B5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('🚘', style: TextStyle(fontSize: 26)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kenderaan',
                                  style: TextStyle(
                                    color: Color(0xFF1B2A4A),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Vehicle',
                                  style: TextStyle(
                                    color: Color(0xFF8B7355),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ),

                      //numbers notes
                      GestureDetector(
                        onTap: () {
                          final category = allCategories.firstWhere((c) => c.name == 'Nombor');
                          _navigateToCategory(category);
                        },
                        child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4C9B5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('🔢', style: TextStyle(fontSize: 26)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombor',
                                  style: TextStyle(
                                    color: Color(0xFF1B2A4A),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Numbers',
                                  style: TextStyle(
                                    color: Color(0xFF8B7355),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ),

                      //colours notes
                      GestureDetector(
                        onTap: () {
                          final category = allCategories.firstWhere((c) => c.name == 'Warna');
                          _navigateToCategory(category);
                        },
                        child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A4A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('🎨', style: TextStyle(fontSize: 26)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Warna',
                                  style: TextStyle(
                                    color: Color(0xFFF5F0E8),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Colours',
                                  style: TextStyle(
                                    color: Color(0xFFC8B89A),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ),

                      //fruits notes
                      GestureDetector(
                        onTap: () {
                          final category = allCategories.firstWhere((c) => c.name == 'Buah-buahan');
                          _navigateToCategory(category);
                        },
                        child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A4A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('🍉', style: TextStyle(fontSize: 26)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buah-buahan',
                                  style: TextStyle(
                                    color: Color(0xFFF5F0E8),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Fruits',
                                  style: TextStyle(
                                    color: Color(0xFFC8B89A),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ),

                      //animals notes
                      GestureDetector(
                        onTap: () {
                          final category = allCategories.firstWhere((c) => c.name == 'Haiwan');
                          _navigateToCategory(category);
                        },
                        child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4C9B5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('🙉', style: TextStyle(fontSize: 26)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Haiwan',
                                  style: TextStyle(
                                    color: Color(0xFF1B2A4A),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Animals',
                                  style: TextStyle(
                                    color: Color(0xFF8B7355),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 24),

                  //daily practice section
                  const Text(
                    'Daily Practice',
                    style: TextStyle(
                      color: Color(0xFF1B2A4A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  //challenge card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD4C9B5)),
                    ),
                    child: Row(
                      children: [

                        //icon box
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2A4A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '🗝️',
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        //questions
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What does "${dailyWord.bmWord}" mean?',
                                style: const TextStyle(
                                  color: Color(0xFF1B2A4A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Tap to try today's quiz",
                                style: TextStyle(
                                  color: Color(0xFF8B7355),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        //the start button
                        GestureDetector(
                          onTap: widget.onNavigateToQuiz,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8B89A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                color: Color(0xFF1B2A4A),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}