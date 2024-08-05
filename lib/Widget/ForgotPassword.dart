import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'LoginScreen.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailErrorText;
  String? _resetPasswordError;
  bool _isSendingResetEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
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
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LoginPage())); // Quay lại màn hình trước đó
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
                  borderSide:
                      BorderSide(color: Colors.blue), // Viền khi chưa focus
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: _isSendingResetEmail ? null : _sendResetEmail,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue), // Màu nền xanh
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Màu chữ trắng
                ),
                child: _isSendingResetEmail
                    ? CircularProgressIndicator()
                    : Text(
                        'Send Reset Email',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold, // Phông chữ là Roboto
                        ),
                      ),
              ),
            ),
            if (_resetPasswordError != null) ...[
              SizedBox(height: 20.0),
              Text(
                _resetPasswordError!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendResetEmail() async {
    String email = _emailController.text;
    bool emailValid = _validateEmail(email);

    setState(() {
      _emailErrorText = emailValid ? null : 'Invalid email';
      _resetPasswordError = null;
    });

    if (emailValid) {
      setState(() {
        _isSendingResetEmail = true;
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showResetEmailSentDialog();
      } catch (e) {
        setState(() {
          _resetPasswordError =
              'Failed to send reset email. Please try again later.';
          _isSendingResetEmail = false;
        });
      }
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showResetEmailSentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Email Sent'),
          content: Text(
              'An email with instructions to reset your password has been sent'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
