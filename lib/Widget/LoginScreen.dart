import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:post_house_rent_app/Widget/ForgotPassword.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import '../MongoDb_Connect.dart';
import 'Register.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800], // Màu xám đậm cho appbar
      ),
      backgroundColor: Colors.black, // Màu đen cho body của Scaffold
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _isLoading = false;
  String? _loginError;
  late SharedPreferences prefs;
  bool _disposed = false; // Biến để kiểm tra xem widget đã dispose chưa

  @override
  void dispose() {
    _disposed = true; // Đánh dấu widget đã dispose
    super.dispose();
  }

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
        SizedBox(height: 20.0),
        TextField(
          controller: _emailController,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.blue, // Đặt màu chữ khi chưa focus
          ),
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: _emailErrorText,
            labelStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
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
          style: TextStyle(
            fontFamily: 'Roboto', // Đặt phông chữ là Roboto
          ),
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: _passwordErrorText,
            labelStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
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
        Container(
          width: MediaQuery.of(context).size.width, // Độ rộng của màn hình
          child: ElevatedButton(
            onPressed: _isLoading || _disposed
                ? null
                : _login, // Kiểm tra điều kiện để enable hoặc disable nút
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blue), // Màu nền xanh
              foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white), // Màu chữ trắng
            ),
            child: _isLoading
                ? CircularProgressIndicator()
                : Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold, // Phông chữ là Roboto
                    ),
                  ),
          ),
        ),
        if (_loginError != null) ...[
          SizedBox(height: 20.0),
          Text(
            _loginError!,
            style: TextStyle(
              color: Colors.red,
              fontFamily: 'Roboto',
            ),
          ),
        ],
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
                print('Navigate to register page');
              },
              child: Text(
                'Register',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(width: 10.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage()));
                print('Navigate to forgot password page');
              },
              child: Text(
                'Forgot Password',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        OutlinedButton.icon(
          onPressed: () {
            signInWithGoogle();
            print('Login with Gmail');
          },
          style: ButtonStyle(
            side: MaterialStateProperty.all<BorderSide>(
              BorderSide(color: Colors.blue), // Đổi màu viền thành màu xanh
            ),
          ),
          icon: Icon(Icons.mail, color: Colors.blue),
          label: Text(
            'Login with Gmail',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  void _login() async {
    if (_disposed) return; // Kiểm tra xem widget đã dispose chưa
    String email = _emailController.text;
    String password = _passwordController.text;

    bool emailValid = EmailValidator.validate(email);
    bool passwordValid = password.isNotEmpty && password.length >= 6;

    setState(() {
      _emailErrorText = emailValid ? null : 'Invalid email or empty';
      _passwordErrorText =
          passwordValid ? null : 'Password must be at least 6 characters long';
      _loginError = null;
    });

    if (emailValid && passwordValid) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          print("Dang nhap thanh cong");
          prefs = await SharedPreferences.getInstance();
          prefs.setBool('login', false);
          Map<String, dynamic>? user = await MongoDatabase.getUser(email);
          String userEmail = user?['email'];
          String username = user?['username'];
          String userImage = user?['image'];
          prefs.setString('username', username);
          prefs.setString('email', userEmail);
          prefs.setString('image', userImage);
          prefs.setString('type', 'system');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          setState(() {
            _loginError = "Account or password is incorrect";
          });
        }
      } catch (e) {
        setState(() {
          _loginError = "Error occurred while logging in: $e";
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  signInWithGoogle() async {
    if (_disposed) return; // Kiểm tra xem widget đã dispose chưa
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(googleUser!.displayName);
      await user.updatePhotoURL(googleUser!.photoUrl);
      await user.reload();
      bool checkAccount = await MongoDatabase.checkGmailtoCreate(
          user.email, user.displayName, user.phoneNumber, user.photoURL);
      print("Dang nhap thanh cong");
      prefs = await SharedPreferences.getInstance();
      prefs.setBool('login', false);
      Map<String, dynamic>? search = await MongoDatabase.getUser(user.email);
      String userEmail = search?['email'];
      String username = search?['username'];
      String userImage = search?['image'];
      prefs.setString('username', username);
      prefs.setString('email', userEmail);
      prefs.setString('image', userImage);
      prefs.setString('type', 'gmail');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
