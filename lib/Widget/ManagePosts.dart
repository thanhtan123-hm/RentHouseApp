import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';
import 'CreatePost.dart';
import 'package:intl/intl.dart';
import 'package:post_house_rent_app/Widget/DetailPage.dart';
import 'package:post_house_rent_app/Widget/AllPosts.dart';
import 'package:post_house_rent_app/Widget/AllSharePosts.dart';

import 'EditPost.dart';

class Manageposts extends StatefulWidget {
  @override
  _ShowManagePostState createState() => _ShowManagePostState();
}

class _ShowManagePostState extends State<Manageposts> {
  late String email = 'nologin';
  late String OwnerId = 'noId';
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
    });
    String? getOwnerId = await MongoDatabase.get_IdfromUser(email);
    setState(() {
      OwnerId = getOwnerId!;
    });
  }

  Future<void> fetchData() async {
    var fetchedPosts = await MongoDatabase.list_post_owner(OwnerId);
    fetchedPosts.sort((a, b) {
      DateTime dateTimeA = DateTime.parse(a['createdAt']);
      DateTime dateTimeB = DateTime.parse(b['createdAt']);
      return dateTimeB.compareTo(dateTimeA); // Sắp xếp từ mới đến cũ
    });
    setState(() {
      posts = fetchedPosts;
    });
  }

  Future<void> _DeletePost(String _id) async {
    bool delete = await MongoDatabase.DeletePost(_id);
    if (delete) {
      await fetchData(); // Làm mới danh sách sau khi xóa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tin đã đăng',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // hoặc chọn một font chữ khác phù hợp
            fontWeight: FontWeight.bold, // hoặc chọn kiểu chữ phù hợp
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: MongoDatabase.list_post_owner(OwnerId).then((posts) {
                  posts.sort((a, b) {
                    DateTime dateTimeA = DateTime.parse(a['createdAt']);
                    DateTime dateTimeB = DateTime.parse(b['createdAt']);
                    return dateTimeB
                        .compareTo(dateTimeA); // Sắp xếp từ mới đến cũ
                  });
                  return posts;
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 2.9 /
                            2.5, // Chỉnh tỷ lệ chiều rộng và chiều cao của mỗi mục
                      ),
                      itemCount: snapshot.data!.length,

                      padding: EdgeInsets.all(8.0),
                      // Khoảng cách giữa các mục
                      itemBuilder: (context, index) {
                        var post = snapshot.data![index];
                        DateTime now = DateTime.now();
                        DateTime postCreatedAt =
                            DateTime.parse(post['createdAt']);
                        Duration difference = now.difference(postCreatedAt);
                        String formattedTime;
                        if (difference.inMinutes < 60) {
                          formattedTime = "${difference.inMinutes} phút trước";
                        } else if (difference.inHours < 24) {
                          formattedTime = "${difference.inHours} giờ trước";
                        } else if (difference.inDays < 7) {
                          formattedTime = "${difference.inDays} ngày trước";
                        } else {
                          formattedTime =
                              DateFormat('dd/MM/yyyy').format(postCreatedAt);
                        }
                        var price = post['price'] / 100000;
                        String gia = '';
                        if (price < 10) {
                          price = price * 100;
                          gia = price.toString() + ' K';
                        } else {
                          price = price / 10;
                          gia = price.toString() + ' Triệu';
                        }

                        return InkWell(
                          onTap: () {
                            // Action when a user card is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(post: post)),
                            );
                          },
                          child: Card(
                            color: Colors.grey[800],
                            margin: EdgeInsets.all(8.0),
                            // Khoảng cách giữa các phần tử trong mỗi mục
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.network(
                                    post['imageUrls'][0],
                                    fit: BoxFit.cover,
                                    // Đảm bảo hình ảnh vừa với kích thước của card
                                    height: 150,
                                    // Điều chỉnh chiều cao của hình ảnh
                                    width: double
                                        .infinity, // Đảm bảo hình ảnh rộng bằng card
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.location_on,
                                              size: 16, color: Colors.white),
                                        ),
                                        TextSpan(
                                          text: " " + post['address'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily:
                                                'Roboto', // hoặc chọn một font chữ khác phù hợp
                                            fontWeight: FontWeight
                                                .bold, // hoặc chọn kiểu chữ phù hợp
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.square_foot,
                                              size: 16, color: Colors.white),
                                        ),
                                        TextSpan(
                                            text: "Diện tích: " +
                                                post['area'].toString() +
                                                " m2",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    20 // hoặc chọn kiểu chữ phù hợp
                                                )),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.access_time_filled,
                                              size: 16, color: Colors.white),
                                        ),
                                        TextSpan(
                                            text: ' ' + formattedTime,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily:
                                                    'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    16 // hoặc chọn kiểu chữ phù hợp
                                                )),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.attach_money,
                                              size: 20, color: Colors.white),
                                        ),
                                        TextSpan(
                                          text: "Giá: " + gia,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Thêm hai nút ở cuối card
                                  SizedBox(height: 10),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Hành động khi nút đầu tiên được nhấn
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditPost(post: post)),
                                            );
                                          },
                                          child: Text(
                                            'Sửa',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily:
                                                  'Roboto', // hoặc chọn một font chữ khác phù hợp
                                              fontWeight: FontWeight
                                                  .bold, // hoặc chọn kiểu chữ phù hợp
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      Colors.grey[800],
                                                  title: Text(
                                                    'Xác nhận',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Bạn có chắc muốn xóa không?',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                      fontWeight: FontWeight
                                                          .bold, // hoặc chọn kiểu chữ phù hợp
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Đóng hộp thoại
                                                      },
                                                      child: Text(
                                                        'Hủy',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                          fontWeight: FontWeight
                                                              .bold, // hoặc chọn kiểu chữ phù hợp
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context)
                                                            .pop(); // Đóng hộp thoại xác nhận

                                                        // Thực hiện hành động xóa
                                                        await _DeletePost(
                                                            post['_id']
                                                                .toString());

                                                        // Đóng hộp thoại tiến trình
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        'Xóa',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontFamily:
                                                              'Roboto', // hoặc chọn một font chữ khác phù hợp
                                                          fontWeight: FontWeight
                                                              .bold, // hoặc chọn kiểu chữ phù hợp
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .all<Color>(Colors
                                                        .red), // Màu nền nút xóa
                                          ),
                                          child: Text(
                                            'Xóa',
                                            style: TextStyle(
                                              color: Colors
                                                  .white, // Màu chữ nút xóa
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ])
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No post found"));
                  }
                },
              ),
            ],
          ),

          // Add the second column here with similar structure as above
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
