import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proje2/Services/WebSocket.dart';

import 'GameHomePage.dart';

class GameBoardPage extends StatefulWidget {
  final String currentUsername;
  final int currentTimeDuration;
  final int roomID;
  const GameBoardPage({
    super.key,
    required this.roomID,
    required this.currentUsername,
    required this.currentTimeDuration,
  });
  @override
  State<GameBoardPage> createState() => _GameBoardPageState();
}

class _GameBoardPageState extends State<GameBoardPage> {
  final board = const {
    (0, 2): 'K3',
    (0, 12): 'K3',
    (1, 8): 'H2',
    (2, 0): 'K3',
    (7, 7): '⭐',
    (0, 5): 'H2',
    (0, 9): 'H2',
    (1, 1): 'H3',
    (1, 6): 'H2',
    (1, 13): 'H3',
    (2, 7): 'K2',
    (2, 14): 'K3',
    (3, 3): 'K2',
    (3, 11): 'K2',
    (4, 4): 'H3',
    (4, 10): 'H3',
    (5, 0): 'H2',
    (5, 5): 'H2',
    (5, 9): 'H2',
    (5, 14): 'H2',
    (6, 1): 'H2',
    (6, 6): 'H2',
    (6, 8): 'H2',
    (6, 13): 'H2',
    (7, 2): 'K2',
    (7, 12): 'K2',
    (8, 1): 'H2',
    (8, 6): 'H2',
    (8, 8): 'H2',
    (8, 13): 'H2',
    (9, 0): 'H2',
    (9, 5): 'H2',
    (9, 9): 'H2',
    (9, 14): 'H2',
    (10, 4): 'H3',
    (10, 10): 'H3',
    (11, 3): 'K2',
    (11, 11): 'K2',
    (12, 0): 'K3',
    (12, 7): 'K2',
    (12, 14): 'K3',
    (13, 1): 'H3',
    (13, 6): 'H2',
    (13, 8): 'H2',
    (13, 13): 'H3',
    (14, 2): 'K3',
    (14, 5): 'H2',
    (14, 9): 'H2',
    (14, 12): 'K3',
  };
  final List<Map<String, dynamic>> harfHavuz = [
    {'letter': 'A', 'count': 12, 'point': 1},
    {'letter': 'B', 'count': 2, 'point': 3},
    {'letter': 'C', 'count': 2, 'point': 4},
    {'letter': 'Ç', 'count': 2, 'point': 4},
    {'letter': 'D', 'count': 2, 'point': 3},
    {'letter': 'E', 'count': 8, 'point': 1},
    {'letter': 'F', 'count': 1, 'point': 7},
    {'letter': 'G', 'count': 1, 'point': 5},
    {'letter': 'Ğ', 'count': 1, 'point': 8},
    {'letter': 'H', 'count': 1, 'point': 5},
    {'letter': 'I', 'count': 4, 'point': 2},
    {'letter': 'İ', 'count': 7, 'point': 1},
    {'letter': 'J', 'count': 1, 'point': 10},
    {'letter': 'K', 'count': 7, 'point': 1},
    {'letter': 'L', 'count': 7, 'point': 1},
    {'letter': 'M', 'count': 4, 'point': 2},
    {'letter': 'N', 'count': 5, 'point': 1},
    {'letter': 'O', 'count': 3, 'point': 2},
    {'letter': 'Ö', 'count': 1, 'point': 7},
    {'letter': 'P', 'count': 1, 'point': 5},
    {'letter': 'R', 'count': 6, 'point': 2},
    {'letter': 'S', 'count': 3, 'point': 2},
    {'letter': 'Ş', 'count': 2, 'point': 4},
    {'letter': 'T', 'count': 5, 'point': 1},
    {'letter': 'U', 'count': 3, 'point': 2},
    {'letter': 'Ü', 'count': 2, 'point': 4},
    {'letter': 'V', 'count': 1, 'point': 4},
    {'letter': 'Y', 'count': 2, 'point': 3},
    {'letter': 'Z', 'count': 2, 'point': 4},
    {'letter': 'JOKER', 'count': 2, 'point': 0},
  ];

  List<String>? gonderilenHarfler;
  late Map<String, int> harfPuani;
  final List<int> secilenHarfler = [];
  String rakipUsername = "";
  int puan = 0;
  int rakipPuan = 0;
  late String anlikUsername;
  Map<(int, int), String> yerlesmisHarfler = {};
  Map<(int, int), String> yerlestirilmekIstenenHarfler = {};
  List<String>? kelimeList;
  int kalanHarfSayisi = 100;
  late int kalanZaman;
  Timer? moveTimer;
  bool hamleYapildiMi = false;
  bool sirasiMi = false;
  String siraMesaji = "";

  @override
  void initState() {
    super.initState();
    anlikUsername = widget.currentUsername;
    harfPuani = {for (var item in harfHavuz) item['letter']: item['point']};
    _initializeGame();
    baglanti();
    kalanZaman = widget.currentTimeDuration;
    SocketService().kalanHarfSayisi(widget.roomID, (int count) {
      setState(() {
        kalanHarfSayisi = count;
      });
    });

    String mayinAciklama(String tip) {
      switch (tip) {
        case 'PUAN_BOLUNMESI':
          return 'Puanın %30\'u kadar aldın!';
        case 'PUAN_TRANSFERI':
          return 'Kelimenin puanı rakibe aktarıldı!';
        case 'KELIME_IPTALI':
          return 'Kelimen iptal edildi, puan alamadın!';
        default:
          return 'Bilinmeyen mayın!';
      }
    }

    SocketService().mayinaBasildi((data) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mayın tetiklendi: ${mayinAciklama(data)}"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    });

    SocketService().bekleme(() {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              title: Text("Bekleniyor"),
              content: Text("Rakibin bağlanması bekleniyor..."),
            ),
      );
    });


    SocketService().oyunBitti((String winner, int score) {
      if (!mounted) return;
      moveTimer?.cancel();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
          title: const Text("Oyun Bitti"),
          content: Text("$winner oyunu kazandı!\nSkor: $score"),
          actions: [
            TextButton(
              onPressed: () {
                SocketService().disconnect();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => GameHomePage(username: anlikUsername, winRatio: 0.0,)),
                );
              },
              child: const Text("Ana Sayfa"),
            ),
          ],
        ),
      );
    });

    SocketService().siraFonk('your_turn', () {
      setState(() {
        sirasiMi = true;
        siraMesaji = "Sıra sende!";
      });
    });

    SocketService().siraFonk('waiting_turn', () {
      setState(() {
        sirasiMi = false;
        siraMesaji = "Sıra rakipte!";
      });
    });


    SocketService().siraFonk('not_your_turn', () {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sıra sizde değil!")));
    });

    SocketService().oyunBasliyor(() {
      if (!mounted) return;
      Navigator.of(context).pop(); // Bekleme ekranını kapat
      startMoveTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rakibin geldi, oyun başlıyor!")),
      );
    });

  }

  Future<void> _initializeGame() async {
    try {
      final lines = await rootBundle.loadString('assets/kelimeler.txt');
      setState(() {
        kelimeList = lines.split('\n');
      });
    } catch (e) {
      setState(() {
        kelimeList = [];
      });
    }
  }

  void baglanti() {
    SocketService().connect(
      widget.roomID,
      widget.currentTimeDuration,
      anlikUsername,
      (Map<String, dynamic> data) {
        setState(() {
          var boardDataRaw = data['boardData'];
          if (boardDataRaw != null) {
            var boardData = boardDataRaw as Map<String, dynamic>;
            yerlesmisHarfler = boardData.map<(int, int), String>((
              key,
              value,
            ) {
              final parts = key.split(',');
              return MapEntry((
                int.parse(parts[0]),
                int.parse(parts[1]),
              ), value);
            });
          }

          var oyuncularRaw = data['oyuncular'];
          if (oyuncularRaw != null) {
            List oyuncular = oyuncularRaw;
            for (var oyuncu in oyuncular) {
              if (oyuncu['username'] == anlikUsername) {
                puan = oyuncu['puan'];
              } else {
                rakipUsername = oyuncu['username'];
                rakipPuan = oyuncu['puan'];
              }
            }
          }
        });
      },
    );

    SocketService().kelimeAl(widget.roomID, (List<String> letters) {
      setState(() {
        gonderilenHarfler = letters;
      });
    });
  }

  Color ozelBolgeRenk(String? type) {
    switch (type) {
      case 'H2':
        return Colors.blue.shade200;
      case 'H3':
        return Colors.pink.shade200;
      case 'K2':
        return Colors.green.shade200;
      case 'K3':
        return Colors.brown.shade300;
      case '⭐':
        return Colors.orange.shade300;
      default:
        return Colors.grey.shade200;
    }
  }

  String? ozelBolgeler(String? type) {
    switch (type) {
      case 'H2':
      case 'H3':
      case 'K2':
      case 'K3':
        return type;
      case '⭐':
        return '⭐';
      default:
        return '';
    }
  }

  String? haritayaYerlesmisHarfler(int row, int col) {
    return yerlestirilmekIstenenHarfler[(row, col)] ?? yerlesmisHarfler[(row, col)];
  }

  void startMoveTimer() {
    moveTimer?.cancel();
    moveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (kalanZaman > 0) {
        setState(() {
          kalanZaman--;
        });
      } else {
        timer.cancel();
        SocketService().sureBitti(widget.roomID);
      }
      SocketService().getBoard(widget.roomID, (Map<String, dynamic> data) {
        setState(() {
          var boardDataRaw = data['boardData'];
          if (boardDataRaw != null) {
            var boardData = boardDataRaw as Map<String, dynamic>;
            yerlesmisHarfler = boardData.map<(int, int), String>((
              key,
              value,
            ) {
              final parts = key.split(',');
              return MapEntry((
                int.parse(parts[0]),
                int.parse(parts[1]),
              ), value);
            });
          }
        });
      });
    });
  }



  bool temasVarMi(
    Map<(int, int), String> hareket,
    Map<(int, int), String> yerlestirilenHarfler,
  ) {
    if (yerlestirilenHarfler.isEmpty) {
      return true;
    }
    for (final position in hareket.keys) {
      final adjacentPositions = [
        (position.$1 - 1, position.$2),
        (position.$1 + 1, position.$2),
        (position.$1, position.$2 - 1),
        (position.$1, position.$2 + 1),
      ];

      for (final adj in adjacentPositions) {
        if (yerlestirilenHarfler.containsKey(adj)) {
          return true;
        }
      }
    }

    return false;
  }

  //gelen harflerin olduğu kısım
  Widget harfCubugu() {
    if (gonderilenHarfler == null) {
      return const CircularProgressIndicator();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(gonderilenHarfler!.length, (index) {
          final letter = gonderilenHarfler![index];
          final isSelected = secilenHarfler.contains(index);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  secilenHarfler.remove(index);
                } else {
                  secilenHarfler.add(index);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.deepPurple.shade100, blurRadius: 6, offset: Offset(2, 2))]
                    : [],
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget onaylaButon() {
    var moveKeys = yerlestirilmekIstenenHarfler.keys.toList();
    String yerlesmisKelime = '';
    int wordScore = 0;
    bool anlamliMi = false;

    if (moveKeys.isEmpty) {
      yerlesmisKelime = '';
      wordScore = 0;
      anlamliMi = false;
    }

    // Tek harf yerleştirilmişse
    if (moveKeys.length == 1) {
      yerlesmisKelime = yerlestirilmekIstenenHarfler[moveKeys.first]!;
      wordScore = yerlesmisKelime
          .split('')
          .fold<int>(0, (sum, letter) => sum + (harfPuani[letter] ?? 0));
      anlamliMi =
          (kelimeList != null) &&
          kelimeList!.any(
            (satir) =>
                satir.toLowerCase().trim() == yerlesmisKelime.toLowerCase(),
          );
    } else if (moveKeys.length > 1) {
      // Birden fazla harf yerleştirilmişse yön kontrolü yapılır
      moveKeys.sort((a, b) {
        if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
        return a.$2.compareTo(b.$2);
      });

      final first = moveKeys.first;
      final second = moveKeys[1];
      final dirRow = second.$1 - first.$1;
      final dirCol = second.$2 - first.$2;
      moveKeys.sort((a, b) {
        if (dirRow != 0) {
          return a.$1.compareTo(b.$1);
        } else if (dirCol != 0) {
          return a.$2.compareTo(b.$2);
        } else {
          return (a.$1 + a.$2).compareTo(b.$1 + b.$2);
        }
      });

      if (dirRow == -1 || dirCol == -1) {
        moveKeys = moveKeys.reversed.toList();
      }

      yerlesmisKelime = moveKeys.map((pos) => yerlestirilmekIstenenHarfler[pos]!).join();
      wordScore = moveKeys.fold<int>(
        0,
        (sum, pos) => sum + (harfPuani[yerlestirilmekIstenenHarfler[pos]!] ?? 0),
      );
      anlamliMi =
          kelimeList != null &&
          kelimeList!.any(
            (satir) =>
                satir.toLowerCase().trim() == yerlesmisKelime.toLowerCase(),
          );
    } else {
      yerlesmisKelime = '';
      wordScore = 0;
      anlamliMi = false;
    }

    return Column(
      children: [
        Text(
          "Seçilen Kelime: $yerlesmisKelime",
          style: TextStyle(
            fontSize: 18,
            color: anlamliMi ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text("Kelime Puanı: $wordScore", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Onayla"),
              onPressed:
                  sirasiMi
                      ? () {
                        if (yerlestirilmekIstenenHarfler.isEmpty) return;

                        bool temas = temasVarMi(
                          yerlestirilmekIstenenHarfler,
                          yerlesmisHarfler,
                        );

                        if (yerlesmisHarfler.isNotEmpty && !temas) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Kelime mevcut harflerden en az birine temas etmeli!",
                              ),
                            ),
                          );
                          return;
                        }

                        if (!anlamliMi) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Girilen kelime geçerli bir kelime değil!",
                              ),
                            ),
                          );
                          return;
                        }

                        final wordData = yerlestirilmekIstenenHarfler.map((key, value) {
                          return MapEntry("${key.$1},${key.$2}", value);
                        });

                        SocketService().harfYerlestir(widget.roomID, wordData);

                        SocketService().kelimeAl(widget.roomID, (
                          List<String> letters,
                        ) {
                          setState(() {
                            gonderilenHarfler = letters;
                          });
                        });

                        SocketService().kalanHarfSayisi(widget.roomID, (
                          int count,
                        ) {
                          setState(() {
                            kalanHarfSayisi = count;
                          });
                        });

                        setState(() {
                          yerlesmisHarfler.addAll(yerlestirilmekIstenenHarfler);
                          yerlestirilmekIstenenHarfler.clear();
                          secilenHarfler.clear();
                          sirasiMi = false;
                        });
                      }
                      : null,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.pause_circle_outline),
              label: const Text("Pas"),
              onPressed:
                  sirasiMi
                      ? () {
                        setState(() {
                          gonderilenHarfler = [];
                        });

                        SocketService().pasYap(widget.roomID, (
                          List<String> yeniHarfler,
                        ) {
                          setState(() {
                            gonderilenHarfler = yeniHarfler;
                            secilenHarfler.clear();
                            yerlestirilmekIstenenHarfler.clear();
                            sirasiMi = false;
                          });
                        });
                      }
                      : null,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.flag),
              label: const Text("Teslim Ol"),
              onPressed: () {
                SocketService().teslimOl(widget.roomID);
                moveTimer?.cancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      appBar: AppBar(
        title: const Text("Oyun Tahtası"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            SocketService().disconnect();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  siraMesaji,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: sirasiMi ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.person, color: Colors.indigo),
                      Text(
                        anlikUsername,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Puan: $puan"),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.hourglass_bottom, color: Colors.orange),
                      const Text("Süre"),
                      Text(
                        "${kalanZaman}s",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.redAccent),
                      Text(rakipUsername),
                      Text("Puan: $rakipPuan"),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.apps, color: Colors.green),
                      const Text("Kalan Harf"),
                      Text(
                        kalanHarfSayisi.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                itemCount: 15 * 15,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 15,
                ),
                itemBuilder: (context, index) {
                  final row = index ~/ 15;
                  final col = index % 15;
                  final kareTipi = board[(row, col)];
                  final tileColor = ozelBolgeRenk(kareTipi);
                  final label = ozelBolgeler(kareTipi);
                  //haritaya tıklama kontrolleri
                  return GestureDetector(
                    onTap: () {
                      if (!sirasiMi) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sıra sizde değil!")),
                        );
                        return;
                      }
                      if (yerlestirilmekIstenenHarfler.containsKey((row, col))) {
                        setState(() {
                          final removedLetter = yerlestirilmekIstenenHarfler.remove((
                            row,
                            col,
                          ));
                          if (removedLetter != null) {
                            gonderilenHarfler?.add(removedLetter);
                          }
                        });
                        return;
                      }

                      if (secilenHarfler.isEmpty) return;

                      final selectedIndex = secilenHarfler.first;
                      final selectedLetter = gonderilenHarfler?[selectedIndex];
                      final currentKeys = yerlestirilmekIstenenHarfler.keys.toList();

                      // Eski yerleştirilmiş harfler üstüne tıklamayı engelle
                      if (yerlesmisHarfler.containsKey((row, col))) {
                        return;
                      }

                      // Eğer ilk harfi koyuyorsak
                      if (yerlestirilmekIstenenHarfler.isEmpty) {
                        setState(() {
                          yerlestirilmekIstenenHarfler[(row, col)] = selectedLetter!;
                          secilenHarfler.clear();
                          gonderilenHarfler?.removeAt(selectedIndex);
                        });
                        return;
                      }

                      // İkinci harfse yön kontrolü
                      if (yerlestirilmekIstenenHarfler.length == 1) {
                        final firstPos = currentKeys.first;
                        final dr = row - firstPos.$1;
                        final dc = col - firstPos.$2;

                        if ((dr.abs() == 1 && dc.abs() == 0) ||
                            (dc.abs() == 1 && dr.abs() == 0) ||
                            (dr.abs() == 1 && dc.abs() == 1)) {
                          setState(() {
                            yerlestirilmekIstenenHarfler[(row, col)] = selectedLetter!;
                            secilenHarfler.clear();
                            gonderilenHarfler?.removeAt(selectedIndex);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("İkinci harfi bitişik koymalısın!"),
                            ),
                          );
                        }
                        return;
                      }

                      // Doğrultuyu belirle
                      final sortedKeys = currentKeys.toList();
                      sortedKeys.sort((a, b) {
                        if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
                        return a.$2.compareTo(b.$2);
                      });

                      final first = sortedKeys.first;
                      final second = sortedKeys[1];
                      final dirRow = second.$1 - first.$1;
                      final dirCol = second.$2 - first.$2;

                      final last = sortedKeys.last;
                      final expectedRow = last.$1 + dirRow;
                      final expectedCol = last.$2 + dirCol;

                      if (row == expectedRow && col == expectedCol) {
                        setState(() {
                          yerlestirilmekIstenenHarfler[(row, col)] = selectedLetter!;
                          secilenHarfler.clear();
                          gonderilenHarfler?.removeAt(selectedIndex);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Harfler belirlenen doğrultuda ilerlemeli!"),
                          ),
                        );
                      }
                    },

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          ),
                        ],
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Center(
                        child: Text(
                          haritayaYerlesmisHarfler(row, col) ?? (label ?? ''),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                haritayaYerlesmisHarfler(row, col) != null
                                    ? Colors.black87
                                    : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                harfCubugu(),
                const SizedBox(height: 12),
                const SizedBox(height: 8),
                onaylaButon(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
