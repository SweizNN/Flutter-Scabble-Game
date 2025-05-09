import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");

  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final existingUser = await userCollection
          .where("username", isEqualTo: username)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception("Bu kullanıcı adı zaten alınmış");
      }

      // Kullanıcıyı kaydet
      await userCollection.add({
        "username": username,
        "email": email,
        "password": password,
        "win_ratio": 0.0,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final userQuery = await userCollection
          .where("username", isEqualTo: username)
          .where("password", isEqualTo: password)
          .get();

      return userQuery.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
