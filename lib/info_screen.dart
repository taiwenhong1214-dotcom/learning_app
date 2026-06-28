import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/firebase_service.dart';

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
  final String engName;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<VocabItem> items;

  const VocabCategory({
    required this.name,
    required this.engName,
    required this.emoji,
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
    name: 'Keluarga',
    emoji: '👨‍👩‍👧‍👦',
    engName: 'Family',
    icon: Icons.family_restroom_rounded,
    color: const Color(0xFFEF5350),
    items: const [
      VocabItem(bmWord: 'Ibu', engMeaning: 'Mother', exampleSentence: 'Ibu saya pandai masak.', engExample: 'My mother is good at cooking.', category: 'Keluarga'),
      VocabItem(bmWord: 'Bapa', engMeaning: 'Father', exampleSentence: 'Bapa bekerja di pejabat.', engExample: 'Father works in the office.', category: 'Keluarga'),
      VocabItem(bmWord: 'Adik', engMeaning: 'Younger sibling', exampleSentence: 'Adik saya berumur lima tahun.', engExample: 'My younger sibling is five years old.', category: 'Keluarga'),
      VocabItem(bmWord: 'Kakak', engMeaning: 'Older sister', exampleSentence: 'Kakak belajar di universiti.', engExample: 'Older sister studies at the university.', category: 'Keluarga'),
      VocabItem(bmWord: 'Abang', engMeaning: 'Older brother', exampleSentence: 'Abang pandai bermain gitar.', engExample: 'Older brother is good at playing the guitar.', category: 'Keluarga'),
      VocabItem(bmWord: 'Datuk', engMeaning: 'Grandfather', exampleSentence: 'Datuk tinggal di kampung.', engExample: 'Grandfather lives in the village.', category: 'Keluarga'),
      VocabItem(bmWord: 'Nenek', engMeaning: 'Grandmother', exampleSentence: 'Nenek suka berkebun.', engExample: 'Grandmother likes gardening.', category: 'Keluarga'),
      VocabItem(bmWord: 'Anak', engMeaning: 'Child', exampleSentence: 'Anak itu sedang bermain.', engExample: 'The child is playing.', category: 'Keluarga'),
      VocabItem(bmWord: 'Suami', engMeaning: 'Husband', exampleSentence: 'Suami dia seorang doktor.', engExample: 'Her husband is a doctor.', category: 'Keluarga'),
      VocabItem(bmWord: 'Isteri', engMeaning: 'Wife', exampleSentence: 'Isteri dia seorang guru.', engExample: 'His wife is a teacher.', category: 'Keluarga'),
    ],
  ),
  VocabCategory(
    name: 'Kenderaan',
    emoji: '🚘',
    engName: 'Vehicles',
    icon: Icons.directions_car_rounded,
    color: const Color(0xFF42A5F5),
    items: const [
      VocabItem(bmWord: 'Kereta', engMeaning: 'Car', exampleSentence: 'Dia memandu kereta ke tempat kerja.', engExample: 'He drives a car to work.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Bas', engMeaning: 'Bus', exampleSentence: 'Kami naik bas ke sekolah.', engExample: 'We take the bus to school.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Motosikal', engMeaning: 'Motorcycle', exampleSentence: 'Motosikal itu sangat laju.', engExample: 'That motorcycle is very fast.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Basikal', engMeaning: 'Bicycle', exampleSentence: 'Adik suka menunggang basikal.', engExample: 'Younger sibling likes riding a bicycle.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Kapal terbang', engMeaning: 'Aeroplane', exampleSentence: 'Kapal terbang itu besar.', engExample: 'That aeroplane is big.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Lori', engMeaning: 'Lorry/Truck', exampleSentence: 'Lori itu membawa barang.', engExample: 'The lorry is carrying goods.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Teksi', engMeaning: 'Taxi', exampleSentence: 'Saya memanggil sebuah teksi.', engExample: 'I called a taxi.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Kereta api', engMeaning: 'Train', exampleSentence: 'Kereta api tiba tepat pada masanya.', engExample: 'The train arrived on time.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Kapal', engMeaning: 'Ship', exampleSentence: 'Kapal itu belayar di laut.', engExample: 'The ship sails on the sea.', category: 'Kenderaan'),
      VocabItem(bmWord: 'Perahu', engMeaning: 'Boat', exampleSentence: 'Nelayan menggunakan perahu.', engExample: 'Fishermen use boats.', category: 'Kenderaan'),
    ],
  ),
  VocabCategory(
    name: 'Nombor',
    emoji: '🔢',
    engName: 'Numbers',
    icon: Icons.pin_rounded,
    color: const Color(0xFFAB47BC),
    items: const [
      VocabItem(bmWord: 'Satu', engMeaning: 'One', exampleSentence: 'Saya ada satu epal.', engExample: 'I have one apple.', category: 'Nombor'),
      VocabItem(bmWord: 'Dua', engMeaning: 'Two', exampleSentence: 'Dia ada dua kucing.', engExample: 'He/She has two cats.', category: 'Nombor'),
      VocabItem(bmWord: 'Tiga', engMeaning: 'Three', exampleSentence: 'Ada tiga buku di atas meja.', engExample: 'There are three books on the table.', category: 'Nombor'),
      VocabItem(bmWord: 'Empat', engMeaning: 'Four', exampleSentence: 'Rumah itu ada empat bilik.', engExample: 'That house has four rooms.', category: 'Nombor'),
      VocabItem(bmWord: 'Lima', engMeaning: 'Five', exampleSentence: 'Saya belajar lima perkataan baru.', engExample: 'I learned five new words.', category: 'Nombor'),
      VocabItem(bmWord: 'Enam', engMeaning: 'Six', exampleSentence: 'Kelas bermula pukul enam pagi.', engExample: 'Class starts at six in the morning.', category: 'Nombor'),
      VocabItem(bmWord: 'Tujuh', engMeaning: 'Seven', exampleSentence: 'Satu minggu ada tujuh hari.', engExample: 'One week has seven days.', category: 'Nombor'),
      VocabItem(bmWord: 'Lapan', engMeaning: 'Eight', exampleSentence: 'Sotong ada lapan kaki.', engExample: 'An octopus has eight legs.', category: 'Nombor'),
      VocabItem(bmWord: 'Sembilan', engMeaning: 'Nine', exampleSentence: 'Dia berumur sembilan tahun.', engExample: 'He/She is nine years old.', category: 'Nombor'),
      VocabItem(bmWord: 'Sepuluh', engMeaning: 'Ten', exampleSentence: 'Saya dapat sepuluh markah penuh.', engExample: 'I got ten full marks.', category: 'Nombor'),
    ],
  ),
  VocabCategory(
    name: 'Warna',
    emoji: '🎨',
    engName: 'Colours',
    icon: Icons.palette_rounded,
    color: const Color(0xFFFF7043),
    items: const [
      VocabItem(bmWord: 'Merah', engMeaning: 'Red', exampleSentence: 'Bunga itu berwarna merah.', engExample: 'That flower is red.', category: 'Warna'),
      VocabItem(bmWord: 'Biru', engMeaning: 'Blue', exampleSentence: 'Langit berwarna biru.', engExample: 'The sky is blue.', category: 'Warna'),
      VocabItem(bmWord: 'Hijau', engMeaning: 'Green', exampleSentence: 'Daun pokok berwarna hijau.', engExample: 'The tree leaves are green.', category: 'Warna'),
      VocabItem(bmWord: 'Kuning', engMeaning: 'Yellow', exampleSentence: 'Pisang masak berwarna kuning.', engExample: 'A ripe banana is yellow.', category: 'Warna'),
      VocabItem(bmWord: 'Hitam', engMeaning: 'Black', exampleSentence: 'Kucing hitam itu comel.', engExample: 'That black cat is cute.', category: 'Warna'),
      VocabItem(bmWord: 'Putih', engMeaning: 'White', exampleSentence: 'Awan putih di langit.', engExample: 'White clouds in the sky.', category: 'Warna'),
      VocabItem(bmWord: 'Oren', engMeaning: 'Orange', exampleSentence: 'Jus oren sangat sedap.', engExample: 'Orange juice is very delicious.', category: 'Warna'),
      VocabItem(bmWord: 'Ungu', engMeaning: 'Purple', exampleSentence: 'Dia suka warna ungu.', engExample: 'He/She likes the color purple.', category: 'Warna'),
      VocabItem(bmWord: 'Perang', engMeaning: 'Brown', exampleSentence: 'Kasut itu berwarna perang.', engExample: 'Those shoes are brown.', category: 'Warna'),
      VocabItem(bmWord: 'Kelabu', engMeaning: 'Grey', exampleSentence: 'Langit kelabu menandakan hujan.', engExample: 'A grey sky indicates rain.', category: 'Warna'),
    ],
  ),
  VocabCategory(
    name: 'Buah-buahan',
    emoji: '🍉',
    engName: 'Fruits',
    icon: Icons.eco_rounded,
    color: const Color(0xFF66BB6A),
    items: const [
      VocabItem(bmWord: 'Epal', engMeaning: 'Apple', exampleSentence: 'Epal ini sangat rangup.', engExample: 'This apple is very crunchy.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Pisang', engMeaning: 'Banana', exampleSentence: 'Monyet suka makan pisang.', engExample: 'Monkeys like to eat bananas.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Oren', engMeaning: 'Orange', exampleSentence: 'Jus oren ini segar.', engExample: 'This orange juice is fresh.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Tembikai', engMeaning: 'Watermelon', exampleSentence: 'Tembikai baik untuk musim panas.', engExample: 'Watermelon is good for summer.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Mangga', engMeaning: 'Mango', exampleSentence: 'Mangga ini sangat manis.', engExample: 'This mango is very sweet.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Nanas', engMeaning: 'Pineapple', exampleSentence: 'Nanas berwarna kuning.', engExample: 'Pineapples are yellow.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Betik', engMeaning: 'Papaya', exampleSentence: 'Betik kaya dengan vitamin.', engExample: 'Papaya is rich in vitamins.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Anggur', engMeaning: 'Grapes', exampleSentence: 'Anggur ini manis.', engExample: 'These grapes are sweet.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Durian', engMeaning: 'Durian', exampleSentence: 'Raja buah ialah durian.', engExample: 'The king of fruits is the durian.', category: 'Buah-buahan'),
      VocabItem(bmWord: 'Strawberi', engMeaning: 'Strawberry', exampleSentence: 'Kek ini ada strawberi.', engExample: 'This cake has strawberries.', category: 'Buah-buahan'),
    ],
  ),
  VocabCategory(
    name: 'Haiwan',
    emoji: '🙉',
    engName: 'Animals',
    icon: Icons.pets_rounded,
    color: const Color(0xFFFFA726),
    items: const [
      VocabItem(bmWord: 'Kucing', engMeaning: 'Cat', exampleSentence: 'Kucing itu sedang tidur.', engExample: 'The cat is sleeping.', category: 'Haiwan'),
      VocabItem(bmWord: 'Anjing', engMeaning: 'Dog', exampleSentence: 'Anjing itu menyalak.', engExample: 'The dog is barking.', category: 'Haiwan'),
      VocabItem(bmWord: 'Burung', engMeaning: 'Bird', exampleSentence: 'Burung terbang di langit.', engExample: 'Birds fly in the sky.', category: 'Haiwan'),
      VocabItem(bmWord: 'Ikan', engMeaning: 'Fish', exampleSentence: 'Ikan berenang dalam air.', engExample: 'Fish swim in the water.', category: 'Haiwan'),
      VocabItem(bmWord: 'Harimau', engMeaning: 'Tiger', exampleSentence: 'Harimau sangat garang.', engExample: 'Tigers are very fierce.', category: 'Haiwan'),
      VocabItem(bmWord: 'Gajah', engMeaning: 'Elephant', exampleSentence: 'Gajah mempunyai belalai.', engExample: 'Elephants have trunks.', category: 'Haiwan'),
      VocabItem(bmWord: 'Singa', engMeaning: 'Lion', exampleSentence: 'Singa ialah raja rimba.', engExample: 'The lion is the king of the jungle.', category: 'Haiwan'),
      VocabItem(bmWord: 'Lembu', engMeaning: 'Cow', exampleSentence: 'Lembu makan rumput.', engExample: 'Cows eat grass.', category: 'Haiwan'),
      VocabItem(bmWord: 'Kuda', engMeaning: 'Horse', exampleSentence: 'Kuda berlari dengan pantas.', engExample: 'Horses run fast.', category: 'Haiwan'),
      VocabItem(bmWord: 'Monyet', engMeaning: 'Monkey', exampleSentence: 'Monyet memanjat pokok.', engExample: 'Monkeys climb trees.', category: 'Haiwan'),
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
    final uid = FirebaseService.currentUser?.uid ?? 'guest';
    
    setState(() {
      _favourites = (prefs.getStringList('favourites_$uid') ?? []).toSet();
      _learned = (prefs.getStringList('learned_$uid') ?? []).toSet();
    });
    
    // Also sync from Firestore if logged in
    if (FirebaseService.currentUser != null) {
      Set<String> firestoreLearned = {};
      for (final cat in allCategories) {
        final words = await FirebaseService.getLearnedVocab(cat.name);
        firestoreLearned.addAll(words);
      }
      if (firestoreLearned.isNotEmpty) {
        setState(() {
          _learned.addAll(firestoreLearned);
        });
        _saveLearned(); // Save back to local prefs
      }
    }
  }

  Future<void> _saveFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseService.currentUser?.uid ?? 'guest';
    await prefs.setStringList('favourites_$uid', _favourites.toList());
  }

  Future<void> _saveLearned() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseService.currentUser?.uid ?? 'guest';
    await prefs.setStringList('learned_$uid', _learned.toList());
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
    // Find the category of this word to save to Firestore
    String categoryName = 'Unknown';
    for (final cat in allCategories) {
      if (cat.items.any((item) => item.bmWord == bmWord)) {
        categoryName = cat.name;
        break;
      }
    }

    setState(() {
      if (_learned.contains(bmWord)) {
        _learned.remove(bmWord);
        FirebaseService.toggleVocabLearned(categoryName, bmWord, false);
      } else {
        _learned.add(bmWord);
        FirebaseService.toggleVocabLearned(categoryName, bmWord, true);
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
                    child: Center(
                      child: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
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
                        Text(
                          category.engName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFC8B89A),
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


  void _openCategory(VocabCategory category) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(
          category: category,
        ),
      ),
    );
    _loadPreferences(); // Refresh progress when returning
  }

}

// ─────────────────────────────────────────────────────
//  Category Detail Page — Shows all 10 vocab cards
// ─────────────────────────────────────────────────────

class CategoryDetailPage extends StatefulWidget {
  final VocabCategory category;

  const CategoryDetailPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  Set<String> _favourites = {};
  Set<String> _learned = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseService.currentUser?.uid ?? 'guest';
    
    setState(() {
      _favourites = (prefs.getStringList('favourites_$uid') ?? []).toSet();
      _learned = (prefs.getStringList('learned_$uid') ?? []).toSet();
    });
    
    if (FirebaseService.currentUser != null) {
      final words = await FirebaseService.getLearnedVocab(widget.category.name);
      if (words.isNotEmpty) {
        setState(() {
          _learned.addAll(words);
        });
        await prefs.setStringList('learned_$uid', _learned.toList());
      }
    }
  }

  Future<void> _toggleFavourite(String bmWord) async {
    setState(() {
      if (_favourites.contains(bmWord)) {
        _favourites.remove(bmWord);
      } else {
        _favourites.add(bmWord);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseService.currentUser?.uid ?? 'guest';
    await prefs.setStringList('favourites_$uid', _favourites.toList());
  }

  Future<void> _toggleLearned(String bmWord) async {
    setState(() {
      if (_learned.contains(bmWord)) {
        _learned.remove(bmWord);
        FirebaseService.toggleVocabLearned(widget.category.name, bmWord, false);
      } else {
        _learned.add(bmWord);
        FirebaseService.toggleVocabLearned(widget.category.name, bmWord, true);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseService.currentUser?.uid ?? 'guest';
    await prefs.setStringList('learned_$uid', _learned.toList());
  }

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
            isFavourite: _favourites.contains(item.bmWord),
            isLearned: _learned.contains(item.bmWord),
            onToggleFavourite: () => _toggleFavourite(item.bmWord),
            onToggleLearned: () => _toggleLearned(item.bmWord),
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