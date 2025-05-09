import 'package:flutter/material.dart';
import 'package:proje2/GamePage.dart';

class GameDurationSelectionPage extends StatelessWidget {
  final String username;

  const GameDurationSelectionPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⏱️ Oyun Süresi Seç"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              "⚡ Hızlı Oyun",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              icon: Icons.timer,
              title: "2 Dakika",
              duration: 120,
              roomId: 1,
            ),
            _buildCard(
              context,
              icon: Icons.timelapse,
              title: "5 Dakika",
              duration: 300,
              roomId: 2,
            ),
            const SizedBox(height: 28),
            const Text(
              "🕒 Genişletilmiş Oyun",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              icon: Icons.nights_stay,
              title: "12 Saat",
              duration: 12 * 60 * 60,
              roomId: 3,
            ),
            _buildCard(
              context,
              icon: Icons.calendar_today,
              title: "24 Saat",
              duration: 24 * 60 * 60,
              roomId: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {
    required IconData icon,
    required String title,
    required int duration,
    required int roomId,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.85),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameBoardPage(
                roomID: roomId,
                currentUsername: username,
                currentTimeDuration: duration,
              ),
            ),
          );
        },
      ),
    );
  }
}
