class UserMongo {
  final String username;
  final String email;
  final String password;
  final String phone;
  final String? image;
  final String type;
  final DateTime createdAt;
  final DateTime updateAt;// Thêm dấu ? để cho image có thể là null

  UserMongo({
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    this.image,
    required this.type,
    required this.createdAt,
    required this.updateAt// Thêm từ khóa 'this' để trường image có thể là null
  });





}
