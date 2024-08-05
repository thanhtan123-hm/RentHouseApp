import 'dart:async';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:post_house_rent_app/MongoDb_Connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';

class InformationAccount extends StatefulWidget {
  const InformationAccount({super.key});

  @override
  State<InformationAccount> createState() => _InformationAccountState();
}

class _InformationAccountState extends State<InformationAccount> {
  // Khởi tạo các controller cho TextField
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String username = 'nologin';
  String imageUrl = 'https://example.com/default-avatar.png';
  String email = 'noemail';
  String phone = 'phone';
  bool _isLoading = true;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('username') ?? 'User';
      imageUrl =
          prefs.getString('image') ?? 'https://example.com/default-avatar.png';
      _emailController.text = prefs.getString('email') ?? 'abc@gmail.com';
    });
    Map<String, dynamic>? search =
        await MongoDatabase.getUser(prefs.getString('email'));
    setState(() {
      email = prefs.getString('email')!;
      _phoneController.text = search?['phone'];
      _isLoading = false; // Đánh dấu đã tải xong dữ liệu
    });
  }

  // Hàm để chọn hình ảnh từ thư viện máy và lưu lên Firebase Storage
  Future<void> _updateImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return; // Người dùng không chọn ảnh

    String fileName =
        '${_nameController.text}_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('avatars/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(File(image.path));

    uploadTask.then((TaskSnapshot taskSnapshot) async {
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
      bool updateImage = await MongoDatabase.UpdateUserImage(email, imageUrl);

      // Cập nhật imageUrl trong SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('image', imageUrl);
      setState(() {
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(imageUrl),
        );
      });

      // Hiển thị thông báo cập nhật thành công (Optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật avatar thành công'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((onError) {
      // Xử lý lỗi khi tải lên Firebase (Optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật avatar thất bại'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  bool isPhoneNumber(String input) {
    // Sử dụng biểu thức chính quy để kiểm tra xem chuỗi có phải là số điện thoại hay không
    // Biểu thức này sẽ phù hợp với các số điện thoại theo định dạng quốc tế, ví dụ: +12 3456 7890
    final RegExp phoneRegex = RegExp(r'^(?:\+?84|0)(?:\d{9,10})$');
    return phoneRegex.hasMatch(input);
  }

  Future<void> _SaveInformation() async {
    if (_nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[800],
            title: Text(
              'Thông báo',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
            content: Text(
              'Vui lòng nhập tên người dùng ',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                    fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }
    if (_emailController.text.isEmpty ||
        !EmailValidator.validate(_emailController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[800],
            title: Text(
              'Thông báo',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
            content: Text(
              'Vui lòng nhập email và đúng định dạng email ',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                    fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[800],
            title: Text(
              'Thông báo',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
            content: Text(
              'Vui lòng nhập số điện thoại ',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                    fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    if (!isPhoneNumber(_phoneController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[800],
            title: Text(
              'Thông báo',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
            content: Text(
              'Vui lòng nhập đúng định dạng số điện thoại ',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
                    fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }
    bool update = await MongoDatabase.UpdateUser(
        email, _nameController.text, _phoneController.text);
    if (update) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thông tin thành công'),
          duration: Duration(seconds: 2), // Optional duration
        ),
      );

      // Save username to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.setString('username', _nameController.text);
      });
    } else {
      // Show error message if update failed (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thông tin thất bại'),
          duration: Duration(seconds: 2), // Optional duration
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    // Dọn dẹp các controller khi không còn sử dụng để tránh rò rỉ bộ nhớ
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thông tin tài khoản",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Hiển thị tiến trình tải dữ liệu
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _updateImage();
                      //_SaveInformation();
                      // Thực hiện lưu các thông tin đã sửa đổi
                      print("Đã lưu thông tin");
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue), // Màu nền nút xóa
                    ),
                    child: Text(
                      'Cập nhật avatar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily:
                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                        fontWeight:
                            FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên',
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontFamily:
                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily:
                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontFamily:
                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily:
                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _SaveInformation();
                      // Thực hiện lưu các thông tin đã sửa đổi
                      print("Đã lưu thông tin");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      'Lưu Thông Tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily:
                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: Colors.black,
    );
  }
}
