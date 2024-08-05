import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/InformationAcount.dart';
import 'package:post_house_rent_app/Widget/ManageRoomAppointment.dart';
import 'package:post_house_rent_app/Widget/Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'ManagePosts.dart'; // Đảm bảo rằng bạn đã tạo trang đăng nhập

class AccountManager extends StatefulWidget {
  @override
  _AccountManagerState createState() => _AccountManagerState();
}

class _AccountManagerState extends State<AccountManager> {
  String username = 'nologin';
  String imageUrl = 'nologin';
  String typeAccount = '';

  @override
  void initState() {
    super.initState();
    check_if_already_login();
  }

  void check_if_already_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var checklogin = (prefs.getBool('login') ?? true);
    print(checklogin);
    if (checklogin == false) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      imageUrl =
          prefs.getString('image') ?? 'https://example.com/default-avatar.png';
      typeAccount = prefs.getString('type')!;
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);
    await prefs.remove('username');
    await prefs.remove('image');
    await prefs.remove('type');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _managePostScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Manageposts()),
    );
  }

  void _showInformationAccount() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InformationAccount()),
    );
  }

  void _manageRoomAppointment() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageRoomAppointment()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800], // Màu xám đậm cho appbar
      ),
      body: Center(
        child: username == 'nologin' && imageUrl == 'nologin'
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Yêu cầu đăng nhập để sử dụng chức năng này.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily:
                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                      fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                          fontWeight:
                              FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 100.0,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$username',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily:
                            'Roboto', // hoặc chọn một font chữ khác phù hợp
                        fontWeight: FontWeight.bold,
                        fontSize: 30 // hoặc chọn kiểu chữ phù hợp
                        ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _managePostScreen,
                      child: Text(
                        'Quản lí tin đăng',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                          fontWeight:
                              FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _manageRoomAppointment,
                      child: Text(
                        'Lịch hẹn',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                          fontWeight:
                              FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      child: Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily:
                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                          fontWeight:
                              FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible: typeAccount == 'system',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showInformationAccount,
                        child: Text(
                          'Thông tin tài khoản',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                                'Roboto', // hoặc chọn một font chữ khác phù hợp
                            fontWeight:
                                FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
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
