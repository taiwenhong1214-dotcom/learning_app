import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────
//  Learn Screen — Vocab categories, cards, TTS, search
// ─────────────────────────────────────────────────────

// Data model for a vocabulary item
class VocabItem {
  final String bmWord;
  final String engMeaning;
  final String exampleSentence;
  final String engExample;
  final String category;

  const VocabItem({
    required this.bmWord,
    required this.engMeaning,
    required this.exampleSentence,
    required this.engExample,
    required this.category,
  });
}

// Data model for a category
class VocabCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<VocabItem> items;

  const VocabCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.items,
  });
}

// ─────────────────────────────────────────────────────
//  ALL VOCAB DATA (50 items, 10 per category)
// ─────────────────────────────────────────────────────
final List<VocabCategory> allCategories = [
  VocabCategory(
    name: 'Greetings',
    icon: Icons.waving_hand_rounded,
    color: const Color(0xFFFF7043),
    items: const [
      VocabItem(bmWord: 'Selamat pagi', engMeaning: 'Good morning', exampleSentence: 'Selamat pagi, cikgu!', engExample: 'Good morning, teacher!', category: 'Greetings'),
      VocabItem(bmWord: 'Selamat petang', engMeaning: 'Good afternoon', exampleSentence: 'Selamat petang, kawan-kawan.', engExample: 'Good afternoon, friends.', category: 'Greetings'),
      VocabItem(bmWord: 'Selamat malam', engMeaning: 'Good night', exampleSentence: 'Selamat malam, tidur nyenyak.', engExample: 'Good night, sleep tight.', category: 'Greetings'),
      VocabItem(bmWord: 'Apa khabar', engMeaning: 'How are you', exampleSentence: 'Apa khabar? Sihat?', engExample: 'How are you? Healthy?', category: 'Greetings'),
      VocabItem(bmWord: 'Baik', engMeaning: 'Fine', exampleSentence: 'Saya baik, terima kasih.', engExample: 'I am fine, thank you.', category: 'Greetings'),
      VocabItem(bmWord: 'Terima kasih', engMeaning: 'Thank you', exampleSentence: 'Terima kasih atas bantuan anda.', engExample: 'Thank you for your help.', category: 'Greetings'),
      VocabItem(bmWord: 'Sama-sama', engMeaning: "You're welcome", exampleSentence: 'Sama-sama, tiada masalah.', engExample: 'You are welcome, no problem.', category: 'Greetings'),
      VocabItem(bmWord: 'Maaf', engMeaning: 'Sorry', exampleSentence: 'Maaf, saya terlambat.', engExample: 'Sorry, I am late.', category: 'Greetings'),
      VocabItem(bmWord: 'Tolong', engMeaning: 'Please/Help', exampleSentence: 'Tolong bantu saya.', engExample: 'Please help me.', category: 'Greetings'),
      VocabItem(bmWord: 'Selamat tinggal', engMeaning: 'Goodbye', exampleSentence: 'Selamat tinggal, jumpa lagi!', engExample: 'Goodbye, see you again!', category: 'Greetings'),
    ],
  ),
  VocabCategory(
    name: 'Numbers',
    icon: Icons.pin_rounded,
    color: const Color(0xFF42A5F5),
    items: const [
      VocabItem(bmWord: 'Satu', engMeaning: 'One', exampleSentence: 'Saya ada satu epal.', engExample: 'I have one apple.', category: 'Numbers'),
      VocabItem(bmWord: 'Dua', engMeaning: 'Two', exampleSentence: 'Dia ada dua kucing.', engExample: 'He/She has two cats.', category: 'Numbers'),
      VocabItem(bmWord: 'Tiga', engMeaning: 'Three', exampleSentence: 'Ada tiga buku di atas meja.', engExample: 'There are three books on the table.', category: 'Numbers'),
      VocabItem(bmWord: 'Empat', engMeaning: 'Four', exampleSentence: 'Rumah itu ada empat bilik.', engExample: 'That house has four rooms.', category: 'Numbers'),
      VocabItem(bmWord: 'Lima', engMeaning: 'Five', exampleSentence: 'Saya belajar lima perkataan baru.', engExample: 'I learned five new words.', category: 'Numbers'),
      VocabItem(bmWord: 'Enam', engMeaning: 'Six', exampleSentence: 'Kelas bermula pukul enam pagi.', engExample: 'Class starts at six in the morning.', category: 'Numbers'),
      VocabItem(bmWord: 'Tujuh', engMeaning: 'Seven', exampleSentence: 'Satu minggu ada tujuh hari.', engExample: 'One week has seven days.', category: 'Numbers'),
      VocabItem(bmWord: 'Lapan', engMeaning: 'Eight', exampleSentence: 'Sotong ada lapan kaki.', engExample: 'An octopus has eight legs.', category: 'Numbers'),
      VocabItem(bmWord: 'Sembilan', engMeaning: 'Nine', exampleSentence: 'Dia berumur sembilan tahun.', engExample: 'He/She is nine years old.', category: 'Numbers'),
      VocabItem(bmWord: 'Sepuluh', engMeaning: 'Ten', exampleSentence: 'Saya dapat sepuluh markah penuh.', engExample: 'I got ten full marks.', category: 'Numbers'),
    ],
  ),
  VocabCategory(
    name: 'Colours',
    icon: Icons.palette_rounded,
    color: const Color(0xFFAB47BC),
    items: const [
      VocabItem(bmWord: 'Merah', engMeaning: 'Red', exampleSentence: 'Bunga itu berwarna merah.', engExample: 'That flower is red.', category: 'Colours'),
      VocabItem(bmWord: 'Biru', engMeaning: 'Blue', exampleSentence: 'Langit berwarna biru.', engExample: 'The sky is blue.', category: 'Colours'),
      VocabItem(bmWord: 'Hijau', engMeaning: 'Green', exampleSentence: 'Daun pokok berwarna hijau.', engExample: 'The tree leaves are green.', category: 'Colours'),
      VocabItem(bmWord: 'Kuning', engMeaning: 'Yellow', exampleSentence: 'Pisang masak berwarna kuning.', engExample: 'A ripe banana is yellow.', category: 'Colours'),
      VocabItem(bmWord: 'Hitam', engMeaning: 'Black', exampleSentence: 'Kucing hitam itu comel.', engExample: 'That black cat is cute.', category: 'Colours'),
      VocabItem(bmWord: 'Putih', engMeaning: 'White', exampleSentence: 'Awan putih di langit.', engExample: 'White clouds in the sky.', category: 'Colours'),
      VocabItem(bmWord: 'Oren', engMeaning: 'Orange', exampleSentence: 'Jus oren sangat sedap.', engExample: 'Orange juice is very delicious.', category: 'Colours'),
      VocabItem(bmWord: 'Ungu', engMeaning: 'Purple', exampleSentence: 'Dia suka warna ungu.', engExample: 'He/She likes the color purple.', category: 'Colours'),
      VocabItem(bmWord: 'Perang', engMeaning: 'Brown', exampleSentence: 'Kasut itu berwarna perang.', engExample: 'Those shoes are brown.', category: 'Colours'),
      VocabItem(bmWord: 'Kelabu', engMeaning: 'Grey', exampleSentence: 'Langit kelabu menandakan hujan.', engExample: 'A grey sky indicates rain.', category: 'Colours'),
    ],
  ),
  VocabCategory(
    name: 'Food',
    icon: Icons.restaurant_rounded,
    color: const Color(0xFF66BB6A),
    items: const [
      VocabItem(bmWord: 'Nasi', engMeaning: 'Rice', exampleSentence: 'Saya makan nasi setiap hari.', engExample: 'I eat rice every day.', category: 'Food'),
      VocabItem(bmWord: 'Mee', engMeaning: 'Noodles', exampleSentence: 'Mee goreng ini pedas!', engExample: 'These fried noodles are spicy!', category: 'Food'),
      VocabItem(bmWord: 'Ayam', engMeaning: 'Chicken', exampleSentence: 'Ayam goreng sangat sedap.', engExample: 'Fried chicken is very delicious.', category: 'Food'),
      VocabItem(bmWord: 'Ikan', engMeaning: 'Fish', exampleSentence: 'Ikan bakar di tepi pantai.', engExample: 'Grilled fish by the beach.', category: 'Food'),
      VocabItem(bmWord: 'Sayur', engMeaning: 'Vegetables', exampleSentence: 'Makan sayur untuk kesihatan.', engExample: 'Eat vegetables for health.', category: 'Food'),
      VocabItem(bmWord: 'Roti', engMeaning: 'Bread', exampleSentence: 'Roti canai untuk sarapan.', engExample: 'Roti canai for breakfast.', category: 'Food'),
      VocabItem(bmWord: 'Telur', engMeaning: 'Egg', exampleSentence: 'Saya suka telur mata kerbau.', engExample: 'I like sunny-side-up eggs.', category: 'Food'),
      VocabItem(bmWord: 'Susu', engMeaning: 'Milk', exampleSentence: 'Minum susu sebelum tidur.', engExample: 'Drink milk before sleeping.', category: 'Food'),
      VocabItem(bmWord: 'Air', engMeaning: 'Water', exampleSentence: 'Minum air yang banyak.', engExample: 'Drink plenty of water.', category: 'Food'),
      VocabItem(bmWord: 'Buah', engMeaning: 'Fruit', exampleSentence: 'Buah mangga sangat manis.', engExample: 'The mango is very sweet.', category: 'Food'),
    ],
  ),
  VocabCategory(
    name: 'Family',
    icon: Icons.family_restroom_rounded,
    color: const Color(0xFFEF5350),
    items: const [
      VocabItem(bmWord: 'Ibu', engMeaning: 'Mother', exampleSentence: 'Ibu saya pandai masak.', engExample: 'My mother is good at cooking.', category: 'Family'),
      VocabItem(bmWord: 'Bapa', engMeaning: 'Father', exampleSentence: 'Bapa bekerja di pejabat.', engExample: 'Father works in the office.', category: 'Family'),
      VocabItem(bmWord: 'Adik', engMeaning: 'Younger sibling', exampleSentence: 'Adik saya berumur lima tahun.', engExample: 'My younger sibling is five years old.', category: 'Family'),
      VocabItem(bmWord: 'Kakak', engMeaning: 'Older sister', exampleSentence: 'Kakak belajar di universiti.', engExample: 'Older sister studies at the university.', category: 'Family'),
      VocabItem(bmWord: 'Abang', engMeaning: 'Older brother', exampleSentence: 'Abang pandai bermain gitar.', engExample: 'Older brother is good at playing the guitar.', category: 'Family'),
      VocabItem(bmWord: 'Datuk', engMeaning: 'Grandfather', exampleSentence: 'Datuk tinggal di kampung.', engExample: 'Grandfather lives in the village.', category: 'Family'),
      VocabItem(bmWord: 'Nenek', engMeaning: 'Grandmother', exampleSentence: 'Nenek suka berkebun.', engExample: 'Grandmother likes gardening.', category: 'Family'),
      VocabItem(bmWord: 'Anak', engMeaning: 'Child', exampleSentence: 'Anak itu sedang bermain.', engExample: 'The child is playing.', category: 'Family'),
      VocabItem(bmWord: 'Suami', engMeaning: 'Husband', exampleSentence: 'Suami dia seorang doktor.', engExample: 'Her husband is a doctor.', category: 'Family'),
      VocabItem(bmWord: 'Isteri', engMeaning: 'Wife', exampleSentence: 'Isteri dia seorang guru.', engExample: 'His wife is a teacher.', category: 'Family'),
    ],
  ),
];

// ─────────────────────────────────────────────────────
//  InfoScreen — Main category list with search
// ─────────────────────────────────────────────────────
class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _favourites = {};
  Set<String> _learned = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favourites = (prefs.getStringList('favourites') ?? []).toSet();
      _learned = (prefs.getStringList('learned') ?? []).toSet();
    });
  }

  Future<void> _saveFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favourites', _favourites.toList());
  }

  Future<void> _saveLearned() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('learned', _learned.toList());
  }

  void _toggleFavourite(String bmWord) {
    setState(() {
      if (_favourites.contains(bmWord)) {
        _favourites.remove(bmWord);
      } else {
        _favourites.add(bmWord);
      }
    });
    _saveFavourites();
  }

  void _toggleLearned(String bmWord) {
    setState(() {
      if (_learned.contains(bmWord)) {
        _learned.remove(bmWord);
      } else {
        _learned.add(bmWord);
      }
    });
    _saveLearned();
  }

  int _getLearnedCount(VocabCategory category) {
    return category.items.where((item) => _learned.contains(item.bmWord)).length;
  }

  @override
  Widget build(BuildContext context) {
    // If searching, show filtered results across all categories
    if (_searchQuery.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learn BM'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: _buildSearchBar(),
          ),
        ),
        body: _buildSearchResults(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn BM'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildSearchBar(),
        ),
      ),
      body: _buildCategoryList(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search vocab (BM or English)...',
          hintStyle: const TextStyle(color: Color(0xFF8B949E)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8B949E)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8B949E)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1C2333),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allCategories.length,
      itemBuilder: (context, index) {
        final category = allCategories[index];
        final learnedCount = _getLearnedCount(category);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _openCategory(category),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF30363D)),
                boxShadow: [
                  BoxShadow(
                    color: category.color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          category.color,
                          category.color.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$learnedCount/${category.items.length} learned',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8B949E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: learnedCount / category.items.length,
                            backgroundColor: const Color(0xFF30363D),
                            color: category.color,
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF8B949E),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final allItems = allCategories.expand((c) => c.items).toList();
    final filtered = allItems.where((item) {
      return item.bmWord.toLowerCase().contains(_searchQuery) ||
          item.engMeaning.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: const Color(0xFF8B949E)),
            const SizedBox(height: 16),
            Text(
              'No results for "$_searchQuery"',
              style: const TextStyle(color: Color(0xFF8B949E), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _VocabCard(
          item: item,
          isFavourite: _favourites.contains(item.bmWord),
          isLearned: _learned.contains(item.bmWord),
          onToggleFavourite: () => _toggleFavourite(item.bmWord),
          onToggleLearned: () => _toggleLearned(item.bmWord),
        );
      },
    );
  }

  void _openCategory(VocabCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CategoryDetailPage(
          category: category,
          favourites: _favourites,
          learned: _learned,
          onToggleFavourite: _toggleFavourite,
          onToggleLearned: _toggleLearned,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Category Detail Page — Shows all 10 vocab cards
// ─────────────────────────────────────────────────────
class _CategoryDetailPage extends StatefulWidget {
  final VocabCategory category;
  final Set<String> favourites;
  final Set<String> learned;
  final Function(String) onToggleFavourite;
  final Function(String) onToggleLearned;

  const _CategoryDetailPage({
    required this.category,
    required this.favourites,
    required this.learned,
    required this.onToggleFavourite,
    required this.onToggleLearned,
  });

  @override
  State<_CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<_CategoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.items.length,
        itemBuilder: (context, index) {
          final item = widget.category.items[index];
          return _VocabCard(
            item: item,
            isFavourite: widget.favourites.contains(item.bmWord),
            isLearned: widget.learned.contains(item.bmWord),
            onToggleFavourite: () {
              widget.onToggleFavourite(item.bmWord);
              setState(() {}); // Refresh UI
            },
            onToggleLearned: () {
              widget.onToggleLearned(item.bmWord);
              setState(() {}); // Refresh UI
            },
            accentColor: widget.category.color,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  VocabCard — Individual vocabulary item card
// ─────────────────────────────────────────────────────
class _VocabCard extends StatefulWidget {
  final VocabItem item;
  final bool isFavourite;
  final bool isLearned;
  final VoidCallback onToggleFavourite;
  final VoidCallback onToggleLearned;
  final Color accentColor;

  const _VocabCard({
    required this.item,
    required this.isFavourite,
    required this.isLearned,
    required this.onToggleFavourite,
    required this.onToggleLearned,
    this.accentColor = const Color(0xFF5C6BC0),
  });

  @override
  State<_VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends State<_VocabCard> {
  static final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ms-MY'); // Malay language
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    await _tts.speak(widget.item.bmWord);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2333),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isLearned
                ? Colors.green.withValues(alpha: 0.5)
                : const Color(0xFF30363D),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: BM word + actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.bmWord,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.accentColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.engMeaning,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF8B949E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Speaker button
                  IconButton(
                    icon: Icon(
                      _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                      color: _isSpeaking ? widget.accentColor : const Color(0xFF8B949E),
                    ),
                    onPressed: _speak,
                    tooltip: 'Pronounce',
                  ),
                  // Favourite button
                  IconButton(
                    icon: Icon(
                      widget.isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: widget.isFavourite ? Colors.red : const Color(0xFF8B949E),
                    ),
                    onPressed: widget.onToggleFavourite,
                    tooltip: 'Favourite',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Example sentence
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.format_quote_rounded, color: Color(0xFFFFD54F), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.exampleSentence,
                            style: const TextStyle(
                              color: Color(0xFFE6EDF3),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.item.engExample,
                            style: const TextStyle(
                              color: Color(0xFF8B949E),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Category tag + Learned toggle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.item.category,
                      style: TextStyle(
                        color: widget.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: widget.onToggleLearned,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.isLearned
                            ? Colors.green.withValues(alpha: 0.15)
                            : const Color(0xFF30363D).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.isLearned ? Colors.green : const Color(0xFF30363D),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isLearned ? Icons.check_circle_rounded : Icons.circle_outlined,
                            size: 16,
                            color: widget.isLearned ? Colors.green : const Color(0xFF8B949E),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.isLearned ? 'Learned' : 'Mark as Learned',
                            style: TextStyle(
                              color: widget.isLearned ? Colors.green : const Color(0xFF8B949E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}