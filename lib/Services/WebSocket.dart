import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  bool _connected = false;


  void connect(int roomId,int timeDuration,String username,Function(Map<String, dynamic>) onBoardReceived) {
    if (_connected) return;

    socket = IO.io("https://proje2-e7nn.onrender.com", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      _connected = true;
      print("Bağlandı");
      socket.emit('join_room', {
        'roomId': roomId,
        'timeDuration': timeDuration,
        'username': username,
      });
    });


    socket.emit('get_board', roomId);
    socket.on('board_data', (data) {
      onBoardReceived(data as Map<String, dynamic>);
    });




    socket.onDisconnect((_) {
      _connected = false;
      print("Bağlantı kesildi");
    });
  }


  void siraFonk(String eventName, Function() callback) {
    socket.on(eventName, (_) => callback());
  }

  void clearListeners() {
    socket.clearListeners(); // Tüm .on() ile eklenen eventleri temizler
  }

  void getBoard(int roomId,Function(Map<String, dynamic>) onBoardReceived) {
    socket.emit('get_board', roomId);
    socket.on('board_data', (data) {
      onBoardReceived(data as Map<String, dynamic>);
    });
  }


  void kelimeAl(int roomId, Function(List<String>) onLettersReceived) {
    print("harf alındı");
    socket.emit('get_letters', roomId);
    socket.on('your_letters', (data) {
      onLettersReceived(List<String>.from(data));
    });
  }

  void oyunBasliyor(Function() onStart) {
    socket.on('game_start', (_) {
      onStart();
    });
  }

  void bekleme(Function() onWaiting) {
    socket.on('waiting_for_opponent', (_) {
      onWaiting();
    });
  }

  void harfYerlestir(int roomId, Map<String, dynamic> wordData) {
    socket.emit('place_word', {
      'roomId': roomId,
      'wordData': wordData,
    });
  }


  void pasYap(int roomID, Function(List<String>) callback) {
    socket.emit('pass_turn', {
      'roomId': roomID,
    });

    socket.once('your_letters', (data) {
      if (data is List) {
        callback(List<String>.from(data));
      }
    });
  }

  void oyunBitti(Function(String, int) callback) {
    socket.on('game_over', (data) {
      final winner = data['winner'] ?? 'Rakip';
      final score = data['score'] ?? 0;
      callback(winner, score);
    });
  }

  void sureBitti(int roomID) {
    socket.emit("sure_bitti", roomID);
  }

  void teslimOl(int roomId) {
    socket.emit('resign', {
      'roomId': roomId,
    });
  }

  void mayinaBasildi(Function(String) callback) {
    socket.on('mine_triggered', (data) {
      if (data is String) {
        callback(data);
      }
    });
  }


  void kalanHarfSayisi(int roomId, Function(int) onRemainingReceived) {
    socket.emit('get_remaining_tiles', roomId);
    socket.once('remaining_tiles', (data) {
      onRemainingReceived(data as int);
    });
  }


  void disconnect() {
    if (_connected) {
      clearListeners();
      socket.disconnect();
      _connected = false;
      print("Bağlantı kesildi");
    }
  }
}
