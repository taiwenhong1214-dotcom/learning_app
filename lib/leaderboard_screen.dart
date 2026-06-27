import 'package:flutter/material.dart';
import 'services/firebase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = FirebaseService.getLeaderboard();
  }

  Future<void> _refresh() async {
    setState(() {
      _leaderboardFuture = FirebaseService.getLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD54F)));
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading leaderboard',
                style: TextStyle(color: Colors.red.shade400),
              ),
            );
          }

          final users = snapshot.data ?? [];
          
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No scores yet. Be the first to take a quiz!',
                style: TextStyle(color: Color(0xFF8B949E)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFFFFD54F),
            backgroundColor: const Color(0xFF1C2333),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final score = user['totalScore'] ?? 0;
                final name = user['displayName'] ?? 'Anonymous';
                final photo = user['photoURL'] ?? '';
                final isCurrent = user['uid'] == FirebaseService.currentUser?.uid;

                // Determine medal color
                Color? medalColor;
                if (index == 0) medalColor = const Color(0xFFFFD700); // Gold
                else if (index == 1) medalColor = const Color(0xFFC0C0C0); // Silver
                else if (index == 2) medalColor = const Color(0xFFCD7F32); // Bronze

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isCurrent ? const Color(0xFF2D3748) : const Color(0xFF1C2333),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isCurrent ? const Color(0xFF5C6BC0) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: medalColor ?? const Color(0xFF8B949E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF30363D),
                          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                          child: photo.isEmpty ? const Icon(Icons.person, color: Color(0xFF8B949E)) : null,
                        ),
                      ],
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        color: isCurrent ? Colors.white : const Color(0xFFE6EDF3),
                      ),
                    ),
                    subtitle: isCurrent ? const Text('You', style: TextStyle(color: Color(0xFF5C6BC0), fontSize: 12)) : null,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30363D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFFFFD54F), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            score.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
