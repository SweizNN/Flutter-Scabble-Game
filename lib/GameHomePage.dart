import 'package:flutter/material.dart';
import 'SureSecimi.dart';

class GameHomePage extends StatelessWidget {
  final String username;
  final double winRatio;

  const GameHomePage({
    super.key,
    required this.username,
    required this.winRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelime Oyunu"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Kullanıcı Bilgisi Kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.person, size: 30, color: Colors.indigo),
                          const SizedBox(height: 6),
                          Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.emoji_events, size: 30, color: Colors.amber),
                          const SizedBox(height: 6),
                          Text("Başarı: %${winRatio.toStringAsFixed(1)}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Butonlar
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildGameButton(
                      icon: Icons.play_arrow,
                      label: "Yeni Oyun",
                      color: Colors.green,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameDurationSelectionPage(username: username),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildGameButton(
                      icon: Icons.timer,
                      label: "Aktif Oyunlar",
                      color: Colors.orange,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameDurationSelectionPage(username: username),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildGameButton(
                      icon: Icons.history,
                      label: "Biten Oyunlar",
                      color: Colors.redAccent,
                      onPressed: () {
                        // Gelecek özellik: Biten oyunlar ekranı
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
