import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            tooltip: 'Leaderboard',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
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
      body: const Center(
        child: Text('Harathi is working this part...'),
      ),
    );
  }
}