import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';
import 'package:post_house_rent_app/model/User.dart';
import '../MongoDb_Connect.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800], // Đặt màu của AppBar là xanh
        leading: IconButton(
          // Thêm nút back về màn hình đăng nhập
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
            ; // Quay lại màn hình trước đó
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _usernameErrorText;
  String? _emailErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;
  String? _phoneErrorText;
  bool _isLoading = false;
  String _registerError = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 100.0, // Đường kính của hình tròn
            child: Text(
              'WantRoom',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontFamily: 'Roboto', // Đặt phông chữ là Roboto
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            errorText: _usernameErrorText,
            labelStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              // Đặt màu chữ "Email" khi chưa focus
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi focus
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi chưa focus
            ),
          ),
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: _emailErrorText,
            labelStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              // Đặt màu chữ "Email" khi chưa focus
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi focus
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi chưa focus
            ),
          ),
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: _passwordErrorText,
            labelStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              // Đặt màu chữ "Email" khi chưa focus
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi focus
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi chưa focus
            ),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            errorText: _confirmPasswordErrorText,
            labelStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              // Đặt màu chữ "Email" khi chưa focus
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi focus
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi chưa focus
            ),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone',
            errorText: _phoneErrorText,
            labelStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              // Đặt màu chữ "Email" khi chưa focus
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi focus
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Viền khi chưa focus
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Container(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blue), // Màu nền xanh
              foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white), // Màu chữ trắng
            ),
            child: _isLoading
                ? CircularProgressIndicator()
                : Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold, // Phông chữ là Roboto
                    ),
                  ),
          ),
        ),
        if (_registerError == 'Register successful.') ...[
          SizedBox(height: 20.0),
          Text(
            _registerError,
            style: TextStyle(color: Colors.teal),
          ),
        ] else ...[
          SizedBox(height: 20.0),
          Text(
            _registerError,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }

  bool _isPasswordValid(String password) {
    RegExp regex = RegExp(r'^.{6,}$');
    return regex.hasMatch(password);
  }

  bool _isPhoneValid(String phone) {
    RegExp regex = RegExp(r'^\+?[0-9]{10,15}$');
    return regex.hasMatch(phone);
  }

  void _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String phone = _phoneController.text;

    bool usernameValid = username.isNotEmpty;
    bool emailValid = EmailValidator.validate(email);
    bool passwordValid = _isPasswordValid(password);
    bool confirmPasswordValid = password == confirmPassword;
    bool phoneValid = _isPhoneValid(phone);
    String? imageurl = await getUserImageUrl();

    setState(() {
      _usernameErrorText = usernameValid ? null : 'Username cannot be empty';
      _emailErrorText = emailValid ? null : 'Invalid email';
      _passwordErrorText =
          passwordValid ? null : 'Password must be at least 6 characters.';
      _confirmPasswordErrorText =
          confirmPasswordValid ? null : 'Passwords do not match';
      _phoneErrorText = phoneValid ? null : 'Invalid phone number';
      //_registerError = '';
    });

    if (usernameValid &&
        emailValid &&
        passwordValid &&
        confirmPasswordValid &&
        phoneValid) {
      setState(() {
        _isLoading = true;
      });

      UserMongo newUser = UserMongo(
          username: username,
          email: email,
          password: password,
          phone: phone,
          image: imageurl,
          type: "system",
          createdAt: DateTime.now(),
          updateAt: DateTime.now());

      bool userCreated = await MongoDatabase.createUser(newUser);

      setState(() {
        _isLoading = false;
      });

      if (userCreated) {
        try {
          // Đăng ký người dùng vào Authentication của Firebase
          UserCredential authResult =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          // Xác thực thành công
          setState(() {
            _registerError = "Register successful.";
            _usernameController.text = '';
            _emailController.text = '';
            _passwordController.text = '';
            _confirmPasswordController.text = '';
            _phoneController.text = '';
          });
        } catch (e) {
          // Xác thực thất bại
          setState(() {
            _registerError = "Register failed: $e";
          });
        }
      } else {
        setState(() {
          _registerError =
              "Email already in use. Please use a different email.";
        });
      }
    }
  }

  Future<String?> getUserImageUrl() async {
    try {
      // Tạo một đối tượng Reference cho hình ảnh user.jpg trong thư mục "images" trong Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child('images/user.jpg');

      // Lấy URL của hình ảnh
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error getting user image URL: $e');
      return null;
    }
  }
}
