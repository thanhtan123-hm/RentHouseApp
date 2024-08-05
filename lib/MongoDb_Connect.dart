import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:post_house_rent_app/model/Post.dart';
import 'env.dart';
import 'model/User.dart';

class MongoDatabase {
  static Future<List<Map<String, dynamic>>> list_test() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('test');
    Future<List<Map<String, dynamic>>> search = user.find().toList();
    return search;
  }

  static Future<List<Map<String, dynamic>>> list_user() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('User');
    Future<List<Map<String, dynamic>>> search = user.find().toList();
    return search;
  }

  static Future<Map<String, dynamic>?> getUser(String? email) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var users = db.collection('User');
    Map<String, dynamic>? search = await users.findOne({
      'email': email,
    });
    return search;
  }

  static Future<Map<String, dynamic>?> getUserById(String? _id) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var users = db.collection('User');
    var objectId = ObjectId.parse(_id!);
    Map<String, dynamic>? search = await users.findOne({
      '_id': objectId,
    });
    return search;
  }

  static Future<String?> get_IdfromUser(String? email) async {
    if (email == null) {
      return null;
    }

    var db = await Db.create(MONGO_URL);
    await db.open();
    var users = db.collection('User');

    var search = await users.findOne({'email': email});

    await db.close(); // Ensure to close the database connection
    String? IdOwner = search?['_id'].toString();
    IdOwner =
        IdOwner?.substring(IdOwner.indexOf('"') + 1, IdOwner.lastIndexOf('"'));

    return IdOwner;
  }

  static Future<bool> createUser(UserMongo user) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Kiểm tra xem email đã tồn tại chưa
      var existingUser = await users.findOne({
        'email': user.email,
      });
      if (existingUser != null) {
        await db.close();
        return false; // Email đã tồn tại
      }

      // Email chưa tồn tại, tạo người dùng mới
      await users.insert({
        "username": user.username,
        "email": user.email,
        "password": user.password,
        "type": user.type,
        "phone": user.phone,
        "image": user.image,
        "createdAt": DateTime.now(),
        "updateAt": DateTime.now()
      });
      await db.close();
      return true;
    } catch (e) {
      print('Error occurred while creating user: $e');
      return false;
    }
  }

  static Future<bool> checkGmailtoCreate(
      String? email, String? username, String? phone, String? image) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Kiểm tra xem email đã tồn tại chưa
      var existingUser = await users.findOne({'email': email});
      if (existingUser != null) {
        // Email đã tồn tại, cập nhật username và image
        await users.update(
            where.eq('email', email),
            modify
                .set('username', username)
                .set('image', image)
                .set('updatedAt', DateTime.now()));
        await db.close();
        return true; // Đã cập nhật người dùng hiện có
      }

      // Email chưa tồn tại, tạo người dùng mới
      await users.insert({
        "username": username,
        "email": email,
        "type": "gmail",
        "image": image,
        "createdAt": DateTime.now(),
        "updatedAt": DateTime.now(),
      });
      await db.close();
      return true; // Đã tạo người dùng mới
    } catch (e) {
      print('Error occurred while creating or updating user: $e');
      return false;
    }
  }

  static Future<bool> createPost(Post post) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var posts = db.collection('Post');

      // Kiểm tra xem post đã tồn tại chưa
      var existingPost = await posts.findOne({
        'selectedType': post.selectedType,
        'selectedRoomType': post.selectedRoomType,
        'area': post.area,
        'address': post.address,
      });
      if (existingPost != null) {
        await db.close();
        return false; // Email đã tồn tại
      }

      // Email chưa tồn tại, tạo người dùng mới
      await posts.insert(post.toJson());
      await db.close();
      return true;
    } catch (e) {
      print('Error occurred while creating post: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> all_post() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var posts = db.collection('Post');
    Future<List<Map<String, dynamic>>> search = posts.find().toList();
    return search;
  }

  static Future<List<Map<String, dynamic>>> list_post() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var posts = db.collection('Post');
    Future<List<Map<String, dynamic>>> search =
        posts.find({'selectedType': 'Cho thuê'}).toList();
    return search;
  }

  static Future<List<Map<String, dynamic>>> list_ShareRoomPost() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('Post');
    Future<List<Map<String, dynamic>>> search =
        user.find({'selectedType': 'Tìm người ở ghép'}).toList();
    return search;
  }

  static Future<List<Map<String, dynamic>>> list_search_post(
      String province, String district, String commune) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var post = db.collection('Post');

    List<Map<String, dynamic>> search;

    // When all parameters are empty, return all documents
    if (province.isEmpty && district.isEmpty && commune.isEmpty) {
      search = await post.find().toList();
      await db.close();
      return search;
    }

    // Construct the query
    var query = where;
    if (province.isNotEmpty && district.isEmpty && commune.isEmpty) {
      String searchStr = '$province';
      query = query.eq('address', RegExp(searchStr));
    }

    if (province.isNotEmpty && district.isNotEmpty && commune.isEmpty) {
      String searchStr = '$district, $province';
      query = query.eq('address', RegExp(searchStr));
    } else if (province.isNotEmpty &&
        district.isNotEmpty &&
        commune.isNotEmpty) {
      String searchStr = '$commune, $district, $province';
      query = query.eq('address', RegExp(searchStr));
    }

    // Execute the query
    search = await post.find(query).toList();

    await db.close();
    return search;
  }

  static Future<List<Map<String, dynamic>>> fillter_Post(
      String selectedType) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('Post');
    Future<List<Map<String, dynamic>>> search =
        user.find({'selectedType': selectedType}).toList();
    return search;
  }

  static Future<bool> UpdateUser(
      String? email, String? name, String? phone) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Tìm user theo email và cập nhật các trường name và phone
      var result = await users.updateOne(
        where.eq('email', email),
        modify
            .set('username', name)
            .set('phone', phone)
            .set('updateAt', DateTime.now()),
      );

      await db.close();

      // Kiểm tra xem update có thành công hay không
      return result.isSuccess;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> UpdateUserImage(String? email, String? ImageUrl) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Tìm user theo email và cập nhật các trường name và phone
      var result = await users.updateOne(
        where.eq('email', email),
        modify.set('image', ImageUrl).set('updateAt', DateTime.now()),
      );

      await db.close();

      // Kiểm tra xem update có thành công hay không
      return result.isSuccess;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<String?> getEmailfrom_Id(String? _id) async {
    if (_id == null) {
      return null;
    }

    var db = await Db.create(MONGO_URL);
    await db.open();
    var users = db.collection('User');

    var objectId = ObjectId.parse(_id); // Chuyển _id thành ObjectId

    var search = await users.findOne({'_id': objectId});

    await db.close(); // Đảm bảo đóng kết nối cơ sở dữ liệu

    return search?['email']?.toString(); // Trả về email nếu tìm thấy
  }

  static Future<bool> create_Room_Viewing_Appointment(
      String ownerId,
      String usernamebooking,
      String email,
      String tel,
      String Day,
      String Time,
      String idPost) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var list = db.collection('Room_Viewing_Appointment');

      // Email chưa tồn tại, tạo người dùng mới
      await list.insert({
        "ownerId": ownerId,
        "username_person_booking": usernamebooking,
        "email_person_booking": email,
        "phone_person_booking": tel,
        "Day": Day,
        "Time": Time,
        "idPost": idPost,
        "createdAt": DateTime.now(),
      });
      await db.close();
      return true;
    } catch (e) {
      print('Error occurred while creating user: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> list_post_owner(
      String ownerId) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var posts = db.collection('Post');
    Future<List<Map<String, dynamic>>> search =
        posts.find({'ownerId': ownerId}).toList();
    return search;
  }

  static Future<bool> UpdatePost(
    String? IdofPost,
    String? selectedType,
    String? selectedRoomType,
    int area,
    int price,
    List<String> selectedAmenitiesNames,
    String? address,
    String? topic,
    String? phone,
    String? zalophone,
    String? facebookLink,
    String? description,
    List<String> imageUrls,
    String? videoURL,
  ) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var posts = db.collection('Post');

      // Tìm user theo email và cập nhật các trường name và phone
      var objectId = ObjectId.parse(IdofPost!);
      var result = await posts.updateOne(
        where.eq('_id', objectId),
        modify
            .set('selectedType', selectedType)
            .set('selectedRoomType', selectedRoomType)
            .set('area', area)
            .set('price', price)
            .set('selectedAmenitiesNames', selectedAmenitiesNames)
            .set('address', address)
            .set('topic', topic)
            .set('phone', phone)
            .set('zalophone', zalophone)
            .set('facebookLink', facebookLink)
            .set('description', description)
            .set('imageUrls', imageUrls)
            .set('videoURL', videoURL)
            .set('updatedAt', DateTime.now().toIso8601String()),
      );

      await db.close();

      // Kiểm tra xem update có thành công hay không
      return result.isSuccess;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> DeletePost(String? _id) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var posts = db.collection('Post');
      String? IdPost = _id;
      IdPost =
          IdPost?.substring(IdPost.indexOf('"') + 1, IdPost.lastIndexOf('"'));
      var objectId = ObjectId.parse(IdPost!);
      var result = await posts.deleteOne(
        where.eq('_id', objectId),
      );
      await db.close();
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> list_room_appointment_of_owner(
      String _id) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var posts = db.collection('Room_Viewing_Appointment');
    Future<List<Map<String, dynamic>>> search =
        posts.find({'ownerId': _id}).toList();
    return search;
  }

  static Future<Map<String, dynamic>?> getPostById(String _id) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var users = db.collection('Post');
    var objectId = ObjectId.parse(_id!);
    Map<String, dynamic>? search = await users.findOne({
      '_id': objectId,
    });
    return search;
  }

  static Future<bool> DeleteBooking(String? _id) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var bookings = db.collection('Room_Viewing_Appointment');
      String? IdBooking = _id;
      IdBooking = IdBooking?.substring(
          IdBooking.indexOf('"') + 1, IdBooking.lastIndexOf('"'));
      var objectId = ObjectId.parse(IdBooking!);
      var result = await bookings.deleteOne(
        where.eq('_id', objectId),
      );
      await db.close();
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> fetchUI(String userId, String postId) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var posts = db.collection('Favorite_Post');
    var existingPost = await posts.findOne({
      'userId': userId,
      'postId': postId,
    });
    await db.close();
    if (existingPost != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> addFavorite(String userId, String postId) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var posts = db.collection('Favorite_Post');

      // Kiểm tra xem bài viết đã tồn tại chưa
      var existingPost = await posts.findOne({
        'userId': userId,
        'postId': postId,
      });
      if (existingPost != null) {
        await db.close();
        return false; // Bài viết đã tồn tại
      }

      // Bài viết chưa tồn tại, thêm vào danh sách yêu thích
      await posts.insert({
        "userId": userId,
        "postId": postId,
        "createdAt": DateTime.now().toIso8601String(),
      });
      await db.close();

      return true;
    } catch (e) {
      print('Error occurred while adding favorite: $e');
      return false;
    }
  }

  static Future<bool> removeFavorite(String userId, String postId) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var posts = db.collection('Favorite_Post');

      // Kiểm tra xem bài viết đã tồn tại chưa
      var existingPost = await posts.deleteOne({
        'userId': userId,
        'postId': postId,
      });
      await db.close();
      return true;
    } catch (e) {
      print('Error occurred while adding favorite: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getListFavorite(
      String userId) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var posts = db.collection('Favorite_Post');
    // Kiểm tra xem bài viết đã tồn tại chưa
    var existingPost = await posts.find({
      'userId': userId,
    }).toList();
    await db.close();
    return existingPost;
  }

  static Future<List<Map<String, dynamic>>> getFavouritePosts(
      Future<List<Map<String, dynamic>>> favouriteList) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var posts = db.collection('Posts');

    // Await the future to get the actual list of favourite items
    var favouriteItems = await favouriteList;

    // Extract IDs from favouriteItems
    var favouriteIds =
        favouriteItems.map((item) => ObjectId.parse(item['postId'])).toList();

    // Query posts collection for posts with matching IDs
    var query = where.oneFrom('_id', favouriteIds);
    var favouritePosts = await posts.find(query).toList();

    await db.close();
    return favouritePosts;
  }
}
