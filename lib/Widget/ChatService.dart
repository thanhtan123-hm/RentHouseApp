import 'package:mongo_dart/mongo_dart.dart';

import '../env.dart';

class ChatService {
  // get instant of firestore

  // get user stream

  //send message
  Future<void> sendMessage(String receiverId, message, senderId) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var list = db.collection('Messages');
    await list.insert({
      "receiverId": receiverId,
      "senderId": senderId,
      "message": message,
      "createdAt": DateTime.now().toIso8601String(),
    });
    await db.close();
  }

  // get message
}
